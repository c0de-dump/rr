class HealthController < ApplicationController
  # Health check controller

  def show
    # Basic health check - you can add more sophisticated checks here
    render json: {
      status: 'healthy',
      timestamp: Time.current,
      services: {
        database: database_healthy?,
        queue: queue_healthy?
      }
    }
  rescue StandardError => e
    render json: {
      status: 'unhealthy',
      error: e.message,
      timestamp: Time.current
    }, status: :service_unavailable
  end

  private

  def database_healthy?
    ActiveRecord::Base.connection.execute('SELECT 1')
    true
  rescue StandardError
    false
  end

  def queue_healthy?
    # Check if solid_queue tables exist and are accessible
    SolidQueue::Job.count
    true
  rescue StandardError
    false
  end
end
