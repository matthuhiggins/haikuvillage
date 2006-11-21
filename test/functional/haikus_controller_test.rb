require File.dirname(__FILE__) + '/../test_helper'
require 'haikus_controller'

# Re-raise errors caught by the controller.
class HaikusController; def rescue_action(e) raise e end; end

class HaikusControllerTest < Test::Unit::TestCase
  fixtures :haikus

  def setup
    @controller = HaikusController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:haikus)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:haiku)
    assert assigns(:haiku).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:haiku)
  end

  def test_create
    num_haikus = Haiku.count

    post :create, :haiku => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_haikus + 1, Haiku.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:haiku)
    assert assigns(:haiku).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Haiku.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Haiku.find(1)
    }
  end
end
