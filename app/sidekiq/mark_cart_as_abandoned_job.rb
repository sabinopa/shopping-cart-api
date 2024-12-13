class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.active_for(3.hours.ago).find_each(&:mark_as_abandoned)
  end
end
