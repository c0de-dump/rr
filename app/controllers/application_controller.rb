# frozen_string_literal: true

class ApplicationController < ActionController::API # :nodoc:
  # Skip CSRF verification for API endpoints
  skip_before_action :verify_authenticity_token, raise: false

  # Ensure all responses are JSON
  before_action :set_default_response_format

  # Handle errors with JSON responses
  rescue_from StandardError, with: :handle_internal_error
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  private

  def set_default_response_format
    request.format = :json unless params[:format]
  end

  def handle_internal_error(exception)
    Rails.logger.error "Internal Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    render json: {
      error: 'Internal server error',
      message: Rails.env.development? ? exception.message : 'Something went wrong'
    }, status: :internal_server_error
  end

  def handle_parameter_missing(exception)
    render json: {
      error: 'Missing required parameter',
      message: exception.message
    }, status: :bad_request
  end

  def handle_not_found(exception)
    render json: {
      error: 'Not found',
      message: exception.message
    }, status: :not_found
  end
end
