class PasswordResetsController < ApplicationController
  before_action :get_user, :valid_user, :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t("flash.email")
      redirect_to root_path
    else
      flash.now[:danger] = t("flash.email_not")
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, t("concerns.password_resets.pass_has"))
      render :edit
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = t("concerns.password_resets.pass_has")
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
    return if @user
    redirect_to signup_path
    flash[:danger] = t("flash.no_user")
  end

  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_path
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t("concerns.password_resets.pass_reset")
      redirect_to new_password_reset_url
    end
  end
end
