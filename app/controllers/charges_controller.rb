class ChargesController < ApplicationController

  # Necessary for exposing the API
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    customer = Customer.new(customer_params)
    customer.charges.first.organization = Organization.find_by_slug(organization_slug_param)
    if customer.save
      CreateCustomerTokenWorker.perform_async(customer.id, card_token_param)
      render json: { pusher_channel_token: customer.charges.first.pusher_channel_token }, status: :ok
    else
      render json: { error: "Something went wrong. Try again." }, status: :unprocessable_entity 
    end
  rescue ActionController::ParameterMissing
    render json: { error: "You must provide all of the required parameters. Check the documentation." }, status: :unprocessable_entity 
  end

  private

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email, :country, :zip, charges_attributes: [:currency, :amount])
  end

  def card_token_param
    params.require(:card_token)
  end

  def organization_slug_param
    params.require(:organization_slug)
  end
end