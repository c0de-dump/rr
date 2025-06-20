# frozen_string_literal: true

class Api::V1::JobsController < Api::V1::BaseController
  def create
    job_type = params[:job_type] || 'example'
    message = params[:message] || 'Hello from web server!'
    delay = params[:delay].to_i || 0

    case job_type
    when 'example'
      job = ExampleJob.perform_later(message, delay)
      render json: {
        status: 'enqueued',
        job_id: job.job_id,
        job_type: 'ExampleJob',
        message: message,
        delay: delay,
        enqueued_at: Time.current
      }
    else
      render json: { error: 'Invalid job type' }, status: :bad_request
    end
  end

  def status
    job_id = params[:job_id]

    if job_id.blank?
      render json: { error: 'job_id parameter required' }, status: :bad_request
      return
    end

    # Try to find the job in solid_queue
    job = SolidQueue::Job.find_by(id: job_id)

    if job
      render json: {
        job_id: job.id,
        status: job_status(job),
        class_name: job.class_name,
        queue_name: job.queue_name,
        created_at: job.created_at,
        updated_at: job.updated_at
      }
    else
      render json: { error: 'Job not found' }, status: :not_found
    end
  end

  def index
    # Get recent jobs for monitoring
    jobs = SolidQueue::Job.order(created_at: :desc).limit(50)

    render json: {
      jobs: jobs.map do |job|
        {
          job_id: job.id,
          status: job_status(job),
          class_name: job.class_name,
          queue_name: job.queue_name,
          created_at: job.created_at,
          updated_at: job.updated_at
        }
      end,
      total_count: jobs.count
    }
  end

  private

  def job_status(job)
    # Determine job status based on solid_queue job state
    if job.finished_at
      'completed'
    elsif job.claimed_at
      'running'
    else
      'pending'
    end
  end
end
