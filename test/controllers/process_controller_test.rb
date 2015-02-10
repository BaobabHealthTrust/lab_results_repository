require 'test_helper'

class ProcessControllerTest < ActionController::TestCase
  test "should get get_labs" do
    get :get_labs
    assert_response :success
  end

  test "should get create_or_update_labs" do
    get :create_or_update_labs
    assert_response :success
  end

end
