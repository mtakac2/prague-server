class OrganizationsController < ApplicationController
  before_filter :sign_in_if_organization_exists, only: [:create]

  def create
    @organization = Organization.new
    @organization.apply_omniauth(request.env['omniauth.auth'])
    if @organization.save
      sign_in organization
      redirect_to @organization
    else
      render :new, notice: "Something went wrong. Please try again."
    end
  end

  def show
    @organization = Organization.find_by_slug(params[:id])
  end

  def new
    @organization = Organization.new
  end

  def omniauth_failure
    redirect_to new_organization_path, notice: "Something went wrong. Please try again."
  end

  def sign_in_if_organization_exists
    organization = Organization.find_for_stripe_oauth(request.env['omniauth.auth'])
    if organization.present?
      sign_in_and_redirect organization
    end
  end
end
