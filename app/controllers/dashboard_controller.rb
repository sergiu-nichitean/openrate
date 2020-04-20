class DashboardController < ApplicationController
  # TODO: 5. Stats: subscribers, sent emails, opened emails, clicks,
  # unsubscribes, broadcasts, sequences etc.
  # animated counters maybe
  def index
    @page_title = 'Dashboard'
    @active_menu = :root
  end
end
