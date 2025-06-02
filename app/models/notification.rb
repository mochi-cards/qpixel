class Notification < ApplicationRecord
  include CommunityRelated
  belongs_to :user

  delegate :name, to: :community, prefix: true

  def event_type
    return @type if @type.present?

    if m = content.match(/New response to your post (.+)/)
      @post_title = m[1]
      @title = m[1]
      @type = :reply
    elsif m = content.match(/Edit suggested on your (.+)/)
      @title = m[1]
      @type = :edit
    elsif m = content.match(/Your (.+) ability has been suspended. Click for more information./)
      @title = m[1]
      @type = :ability
    elsif m = content.match(/New comment thread on ([^:]+): (.+)/)
      @title = m[1]
      @type = :comment
    elsif m = content.match(/There are new comments in a followed thread '([^']+)' on the post '([^']+)'/)
      @title = m[1]
      @type = :comment
    elsif m = content.match(/You were mentioned in a comment to (.+) on the post '([^']+)'/)
      @title = m[2]
      @type = :mention
    elsif m = content.match(/New feedback on (.+)/)
      @title = m[1]
      @type = :feedback
    else
      @title = content
      @type = :other
    end

    return @type
  end

  def display_type
    case @type
    when :reply
      "New reply"
    when :edit
      "Edit suggested"
    when :ability
      "Ability suspended"
    when :comment
      "New comment"
    when :mention
      "New mention"
    when :feedback
      "New feedback"
    else
      ""
    end
  end

  def title
    event_type
    parent&.title || @title
  end

  def parent
    return @parent if @parent.present?

    if m = link.match(/\/comments\/thread\/(\d+)/)
      @parent = CommentThread.find(m[1].to_i)
      @parent_type = :comment_thread
    elsif m = link.match(/\/posts\/(\d+)/)
      @parent = Post.find(m[1].to_i)
      @parent_type = :post
    else
      nil
      @parent_type = nil
      @parent = nil
    end

    return @parent
  end

  def category
    parent
    if @parent_type == :post
      parent.category
    elsif @parent_type == :comment_thread
      Post.find(parent.post_id).category
    else
      nil
    end
  end

  def parent_type
    parent
    return @parent_type
  end
end

# \/comments\/thread\/(\d+)
# \/posts\/(\d+)

# link: "http://localhost:3001/comments/thread/5#comment-12",
# link: "http://localhost:3001/posts/17/53#answer-53",
# link: "http://localhost:3001/comments/thread/6#comment-14",

# app/controllers/posts_controller.rb
# /New response to your post (.+)/
# 107: "New response to your post #{@post.parent.title}"
# /Edit suggested on your (.+)/
# 329: "Edit suggested on your #{@post_type.name.underscore.humanize.downcase}"
 
# app/controllers/users_controller.rb
# /Your (.+) ability has been suspended. Click for more information./
# 468: "Your #{ability.name} ability has been suspended. Click for more information.",
 
# app/controllers/comments_controller.rb
# /New comment thread on ([^:]+): (.+)/
# 45: "New comment thread on #{@comment.root.title}: #{@comment_thread.title}"
# /There are new comments in a followed thread '([^']+)' on the post '([^']+)'/
# 93: "There are new comments in a followed thread '#{@comment_thread.title}' on the post '#{title}'",
# /You were mentioned in a comment to (.+) on the post '([^']+)'/
# 323: "You were mentioned in a comment to #{@comment_thread.title} on the post '#{title}'",

# app/controllers/flags_controller.rb
# /New feedback on (.+)/
# 104: "New feedback on #{comment.root.title}"
