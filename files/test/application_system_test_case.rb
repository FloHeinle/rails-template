# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  running_in_docker = ENV.fetch('SYSTEM_TESTS_IN_DOCKER', false)
  selenium_url = ENV.fetch('SELENIUM_HOST', 'localhost')

  Capybara.server_host = '0.0.0.0'
  Capybara.app_host = running_in_docker ? "http://#{IPSocket.getaddress(Socket.gethostname)}" : 'http://host.docker.internal'

  # Silence puma messages.
  Capybara.configure do |config|
    config.server = :puma, { Silent: true }
  end

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: { url: "http://#{selenium_url}:4444/wd/hub" }
end
