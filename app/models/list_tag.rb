# frozen_string_literal: true

# == Schema Information
#
# Table name: list_tags
#
#  id         :bigint(8)        not null, primary key
#  list_id    :bigint(8)        not null
#  tag_id     :bigint(8)        not null
#  follow_id  :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ListTag < ApplicationRecord
  belongs_to :list
  belongs_to :tag
  belongs_to :follow

  validates :account_id, uniqueness: { scope: :list_id }

  before_validation :set_follow

  private

  def set_follow
    self.follow = Follow.find_by!(account_id: list.account_id, target_account_id: account.id) unless list.account_id == account.id
  end
end
