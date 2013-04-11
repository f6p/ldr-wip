class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound do |exception|
    redirect_to root_path, :alert => 'Page not found.'
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => 'Access denied.'
  end

  def after_sign_in_path_for resource_or_scope
    current_user
  end

  def after_sign_out_path_for resource_or_scope
    request.referrer
  end

  def authenticate_admin!
    if user_signed_in?
      redirect_to root_path, :alert => 'Unauthorized.' unless current_user.admin?
    else
      redirect_to new_user_session_path
    end
  end

  private

  def generate_token
    session[:token_value] ||= SecureRandom.hex 3
  end

  def items_for_autocomplete base, pattern
    regex = Regexp.new pattern.downcase
    items = base.reject { |i| i.downcase !~ regex }

    items.enum_for(:each_with_index).collect do |item, index|
      Hash[:id, index, :name, "#{item}", :value, "#{item}"]
    end
  end

  def redirect_if_signed_in
    if user_signed_in?
      redirect_to current_user, :alert => 'You are already signed in.'
    end
  end
end
