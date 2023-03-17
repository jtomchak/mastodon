# frozen_string_literal: true

class Api::V1::Lists::TagsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:lists' }, only: [:show]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, except: [:show]

  before_action :require_user!
  before_action :set_list
  # before_action :set_or_create_tag

  after_action :insert_pagination_headers, only: :show

  def show
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def create
    ApplicationRecord.transaction do
      list_tags.each do |tag|
        Rails.logger.info '>>>>>TAG:'
        Rails.logger.info tag
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

  def set_or_create_tag
    return not_found unless Tag::HASHTAG_NAME_RE.match?(params[:id])

    @tag = Tag.find_normalized(params[:id]) || Tag.new(name: Tag.normalize(params[:id]), display_name: params[:id])
  end

  # Get the list by id
  def set_list
    @list = List.where(account: current_account).find(params[:list_id])
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

  ## previous

  # def set_list
  #   @list = List.where(account: current_account).find(params[:list_id])
  # end

  def load_accounts
    if unlimited?
      @list.accounts.without_suspended.includes(:account_stat).all
    else
      @list.accounts.without_suspended.includes(:account_stat).paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    end
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    return if unlimited?

    api_v1_list_accounts_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    return if unlimited?

    api_v1_list_accounts_url pagination_params(since_id: pagination_since_id) unless @accounts.empty?
  end

  def pagination_max_id
    @accounts.last.id
  end

  def pagination_since_id
    @accounts.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def unlimited?
    params[:limit] == '0'
  end
end
