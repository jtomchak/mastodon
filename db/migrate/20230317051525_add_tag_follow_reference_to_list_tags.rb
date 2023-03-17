class AddTagFollowReferenceToListTags < ActiveRecord::Migration[6.1]
  def change
    add_reference :list_tags, :tag_follows, index: false
  end
end
