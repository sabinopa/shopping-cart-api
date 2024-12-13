class RemoveAbandonedCartsJob
  include Sidekiq::Job

  def perform
    Cart.abandoned_for(7.days.ago).find_each(&:remove_if_expired)
  end
end
