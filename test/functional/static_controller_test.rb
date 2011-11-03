require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "should get fu" do
    get :fu
    assert_response :success
  end

end
