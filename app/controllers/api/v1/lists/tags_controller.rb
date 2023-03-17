# frozen_string_literal: true

class Api::V1::Lists::TagsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:lists' }, only: [:show]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, except: [:show]

  before_action :require_user!
  before_action :set_list
  before_action :load_tags

  def show
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user.account_id)
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

  def load_tags
    Rails.logger.info '>>>>>LOAD TAGS'
    Rails.logger.info @list.tags.all.inspect
    @tag = @list.tags.first
  end

  def load_statuses
    cached_tagged_statuses
  end

  def cached_tagged_statuses
    @tag.nil? ? [] : cache_collection(tag_timeline_statuses, Status)
  end

  def tag_timeline_statuses
    tag_feed.get(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id],
      params[:min_id]
    )
  end

  def tag_feed
    TagFeed.new(
      @tag,
      current_account,
      any: params[:any],
      all: params[:all],
      none: params[:none],
      local: truthy_param?(:local),
      remote: truthy_param?(:remote),
      only_media: truthy_param?(:only_media)
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
