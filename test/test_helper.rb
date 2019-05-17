ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase

  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
    !!session[:user_id]
  end
end
