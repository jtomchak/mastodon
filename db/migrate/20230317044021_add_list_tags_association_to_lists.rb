class AddListTagsAssociationToLists < ActiveRecord::Migration[6.1]
  def change
    def self.up
      add_column :list_tags, :tag_name, :string
      add_index 'tags', ['tag_name'], name: 'index_tag_name'
    end

    def self.down
      remove_column :list_tags, :tag_name
    end
  end
end
