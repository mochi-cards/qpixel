module PostsHelper
  def post_markdown(scope, field_name)
    params['__html'].presence || render_markdown(params[scope][field_name])
  end

  def cancel_redirect_path(post)
    if post.id.present?
      post_url(post)
    elsif post.parent_id.present?
      post_url(post.parent_id)
    elsif post.category_id.present?
      category_url(post.category_id)
    else
      root_url
    end
  end

  # @param category [Category, Nil]
  # @return [Integer] the minimum length for post bodies
  def min_body_length(category)
    category&.min_body_length || 30
  end

  # @param _category [Category, Nil]
  # @return [Integer] the maximum length for post bodies
  def max_body_length(_category)
    30_000
  end

  # @param category [Category, Nil] post category, if any
  # @param post_type [PostType] type of the post (system limits are relaxed)
  # @return [Integer] the minimum length for post titles
  def min_title_length(category, post_type)
    if post_type.system?
      1
    else
      category&.min_title_length || 15
    end
  end

  # @param _category [Category, Nil]
  # @return [Integer] the maximum length for post titles
  def max_title_length(_category)
    [SiteSetting['MaxTitleLength'] || 255, 255].min
  end

  class PostScrubber < Rails::Html::PermitScrubber
    def initialize
      super
      # IF YOU CHANGE THESE VALUES YOU MUST ALSO CHANGE app/assets/javascripts/posts.js
      self.tags = %w[a p span b i em strong hr h1 h2 h3 h4 h5 h6 blockquote img strike del code pre br ul ol li sup sub
                     section details summary ins table thead tbody tr th td s]
      self.attributes = %w[id class href title src height width alt rowspan colspan lang start dir]
    end

    def skip_node?(node)
      node.text?
    end
  end

  def scrubber
    PostsHelper::PostScrubber.new
  end

  def get_pingable_for_post(post)
    # For a post, pingable users include:
    # - post author (if editing)
    # - parent post author (if it's an answer)
    # - other answer authors
    # - post history event users
    # - comment authors on the post and its parent

    query = if post.parent_id.present?
              # This is an answer - include parent author and other answer authors
              <<~END_SQL
                SELECT posts.user_id FROM posts WHERE posts.id = #{post.parent_id}
                UNION DISTINCT
                SELECT DISTINCT posts.user_id FROM posts WHERE posts.parent_id = #{post.parent_id}
                UNION DISTINCT
                SELECT DISTINCT ph.user_id FROM post_histories ph WHERE ph.post_id = #{post.id} OR ph.post_id = #{post.parent_id}
                UNION DISTINCT
                SELECT DISTINCT comments.user_id FROM comments WHERE comments.post_id = #{post.id} OR comments.post_id = #{post.parent_id}
              END_SQL
            else
              # This is a top-level post - include answer authors
              <<~END_SQL
                SELECT posts.user_id FROM posts WHERE posts.id = #{post.id}
                UNION DISTINCT
                SELECT DISTINCT posts.user_id FROM posts WHERE posts.parent_id = #{post.id}
                UNION DISTINCT
                SELECT DISTINCT ph.user_id FROM post_histories ph WHERE ph.post_id = #{post.id}
                UNION DISTINCT
                SELECT DISTINCT comments.user_id FROM comments WHERE comments.post_id = #{post.id}
              END_SQL
            end

    ActiveRecord::Base.connection.execute(query).to_a.flatten
  end

  def render_pings_in_post(content, pingable: nil)
    content.gsub(/@#\d+/) do |id|
      u = User.where(id: id[2..-1].to_i).first
      if u.nil?
        id
      else
        was_pung = pingable.present? && pingable.include?(u.id)
        classes = "ping #{u.id == current_user&.id ? 'me' : ''} #{was_pung ? '' : 'unpingable'}"
        user_link u,
          class: classes,
          dir: 'ltr',
          anchortext: "@#{u.rtl_safe_username}",
          title: was_pung ? '' : 'This user was not notified because they have not participated in this post.'
      end
    end.html_safe
  end
end
