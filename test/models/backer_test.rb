require 'test_helper'

class BackerTest < ActiveSupport::TestCase
  def setup
  	@backer1 = backers(:one)
  	@backer2 = backers(:two)
  end

  test "should be valid" do
  	assert @backer1.valid?
  	assert @backer2.valid?
  end

  test "name must be present" do
  	@backer1.full_name = "     "
  	assert_not @backer1.valid?
  end

  test "name should not be too long" do
  	@backer1.full_name = "a" * 21
    assert_not @backer1.valid?
  end

  test "name should not be too short" do
  	@backer1.full_name = "a" * 3
    assert_not @backer1.valid?
  end

  test "name allows underscores and dashes" do
  	@backer2.full_name = "b-la_h"
  	assert @backer2.valid?
  end


end
