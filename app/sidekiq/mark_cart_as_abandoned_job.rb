class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.active.where('last_interaction_at <= ?', 3.hours.ago).find_each(&:mark_as_abandoned)
  end
end
