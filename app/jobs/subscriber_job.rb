class SubscriberJob < ApplicationJob
  queue_as :subscribe

  def perform(*args)
    # Do something later
    puts "SubscriberJob is running with args: #{args.inspect} and trace_id: #{trace_id}"
  end
end
