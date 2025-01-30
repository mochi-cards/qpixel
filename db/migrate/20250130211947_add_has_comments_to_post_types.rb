class AddHasCommentsToPostTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :post_types, :has_comments, :boolean, null: false, default: false
  end
end
