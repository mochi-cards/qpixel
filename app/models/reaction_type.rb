class ReactionType < ApplicationRecord
  include CommunityRelated
  belongs_to :post_type, class_name: 'PostType', optional: true

  validates :name, uniqueness: { scope: [:community_id], case_sensitive: false }

  scope :active, -> { where(active: true) }

  def display_name
    case name
    when 'answer' then
      'Answered'
    when 'done' then
      'Done'
    end
  end
end
