require 'view_test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'title by value' do
    title 'Haiku Village: hello world'
    assert_equal 'hello world', content_for(:title)
  end

  test 'title by block' do
    title { 'hello world' }
    assert_equal 'hello world', content_for(:title)
  end

  test 'body' do
    assert_dom_equal(
      '<body id="action_view_test_case_test" class="index">hello world</body>',
      body { 'hello world' }
    )
  end
end
