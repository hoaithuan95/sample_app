class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :load_micropost, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = t("flash.micropost")
      redirect_to root_path
    else
      @feed_items = []
      render "static_pages/home"
    end
  end

  def destroy
    return unless @micropost.destroy
    flash[:success] = t("flash.d_micropost")
    redirect_to request.referrer || root_path
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end

  def load_micropost
    @micropost = current_user.microposts.find_by(id: params[:id])
    return unless @micropost.nil?
    flash[:danger] = t("flash.no_post")
    redirect_to root_path
  end
end
