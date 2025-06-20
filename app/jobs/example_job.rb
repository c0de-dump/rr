class ExampleJob < ApplicationJob
  queue_as :default

  def perform(message, delay_seconds = 0)
    # Simulate some work
    sleep(delay_seconds) if delay_seconds > 0

    Rails.logger.info "Processing ExampleJob with message: #{message}"
    Rails.logger.info "Job performed at: #{Time.current}"
    Rails.logger.info "Trace ID: #{trace_id}" if trace_id

    # You can add your actual job logic here
    # For example: send emails, process data, call external APIs, etc.

    {
      status: 'completed',
      message: message,
      processed_at: Time.current,
      trace_id: trace_id
    }
  end
end
