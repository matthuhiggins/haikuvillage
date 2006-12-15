require File.dirname(__FILE__) + '/../test_helper'
require 'messaging_controller'

# Re-raise errors caught by the controller.
class MessagingController; def rescue_action(e) raise e end; end

class MessagingControllerTest < Test::Unit::TestCase
  def setup
    @controller = MessagingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
