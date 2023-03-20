class CreateListTags < ActiveRecord::Migration[6.1]
  def change
    create_table :list_tags do |t|
      t.belongs_to :list, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :tag, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :follow, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
    add_index :list_tags, [:tag_id, :list_id], unique: true
    add_index :list_tags, [:list_id, :tag_id]
  end
end

# Based on list_account
# def change
#   create_table :list_tags do |t|
#     t.belongs_to :list, foreign_key: { on_delete: :cascade }, null: false
#     t.belongs_to :tag, foreign_key: { on_delete: :cascade }, null: false
#     t.belongs_to :follow, foreign_key: { on_delete: :cascade }, null: false
#   end

#   add_index :list_tags, [:account_id, :list_id], unique: true
#   add_index :list_tags, [:list_id, :account_id]
# end
