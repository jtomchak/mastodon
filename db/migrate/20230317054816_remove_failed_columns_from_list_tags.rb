class RemoveFailedColumnsFromListTags < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :list_tags, :follow_id }
    safety_assured { remove_column :list_tags, :tag_follows_id }
  end
end
