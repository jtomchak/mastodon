# frozen_string_literal: true

# == Schema Information
#
# Table name: list_tags
#
#  id             :bigint(8)        not null, primary key
#  list_id        :bigint(8)        not null
#  tag_id         :bigint(8)        not null
#  follow_id      :bigint(8)        not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  tag_follows_id :bigint(8)
#

class ListTag < ApplicationRecord
  belongs_to :list
  belongs_to :tag
  belongs_to :tag_follows

  validates :tag_id, uniqueness: { scope: :list_id }

  before_validation :set_tag_follows

  private

  def set_tag_follows
    self.tag_follows = TagFollow.where(tag_id: tag_id, account_id: list.account_id)
  end
end
