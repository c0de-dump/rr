# frozen_string_literal: true

require 'zipkin-tracer'

class ApplicationJob < ActiveJob::Base
  attr_accessor :trace_id

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked
  before_enqueue :with_trace_id
  before_perform :with_trace_id

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def with_trace_id
    self.trace_id ||= ZipkinTracer::TraceGenerator.new.next_trace_id
  end

  def serialize
    super.merge('trace_id' => trace_id)
  end

  def deserialize(job_data)
    super
    self.trace_id = job_data['trace_id']
  end
end
