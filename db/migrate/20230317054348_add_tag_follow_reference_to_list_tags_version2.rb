class AddTagFollowReferenceToListTagsVersion2 < ActiveRecord::Migration[6.1]
  def change
    add_reference :list_tags, :tag_follow, index: false, null: false
  end
end
