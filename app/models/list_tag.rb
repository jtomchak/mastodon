# frozen_string_literal: true

# == Schema Information
#
# Table name: list_tags
#
#  id            :bigint(8)        not null, primary key
#  list_id       :bigint(8)        not null
#  tag_id        :bigint(8)        not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tag_follow_id :bigint(8)        not null
#

class ListTag < ApplicationRecord
  # self.ignored_columns = %w(follow_id tag_follows_id)
  belongs_to :list
  belongs_to :tag
  belongs_to :tag_follow

  validates :tag_id, uniqueness: { scope: :list_id }

  before_validation :set_tag_follow

  private

  def set_tag_follow
    self.tag_follow = TagFollow.find_by!(tag_id: tag_id, account_id: list.account_id)
  end
end
