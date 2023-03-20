# frozen_string_literal: true

class Api::V1::Lists::TagsController < Api::BaseController
  TAGS_LIMIT = 5
  before_action -> { doorkeeper_authorize! :read, :'read:lists' }, only: [:show]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, except: [:show]

  before_action :require_user!
  before_action :set_list
  before_action :set_results

  def show
    render json: @results.map(&:tag), each_serializer: REST::TagSerializer, relationships: TagRelationshipsPresenter.new(@results.map(&:tag), current_user&.account_id)
  end

  def create
    ApplicationRecord.transaction do
      list_tags.each do |tag|
        @list.tags << tag
      end
    end

    render_empty
  end

  def destroy
    ListAccount.where(list: @list, account_id: account_ids).destroy_all
    render_empty
  end

  private

  # Get the list by id
  def set_list
    @list = List.where(account: current_account).find(params[:list_id])
  end

  def set_results
    @results = TagFollow.where(account: current_account).joins(:tag).eager_load(:tag).to_a_paginated_by_id(
      limit_param(TAGS_LIMIT),
      params_slice(:max_id, :since_id, :min_id)
    )
  end

  def list_tags
    # Tag.find(tag_names)
    Tag.find_or_create_by_names(tag_names)
  end

  # Get the body params 'tag_names' a string array of hashtags
  def tag_names
    Array(resource_params[:tag_names])
  end

  def resource_params
    params.permit(tag_names: [])
  end
end
