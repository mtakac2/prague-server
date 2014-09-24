class Api::Tags::ChargesController < Api::BaseController
  before_filter :load_tag

  def index
    render json: @tag.charges.live.paid.order('created_at DESC').paginate(per_page: 100, page: params[:page]).to_json
  end

  private

  def load_tag
    @tag = current_resource_owner.tags.where(name: params[:tag_id]).first!
  end
end
