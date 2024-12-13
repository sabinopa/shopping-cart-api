class RemoveAbandonedCartsJob
  include Sidekiq::Job

  def perform
    Cart.abandoned.where('last_interaction_at <= ?', 7.days.ago).find_each(&:remove_if_abandoned)
  end
end
