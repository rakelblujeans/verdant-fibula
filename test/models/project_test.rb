require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
  	@good1 = projects(:one)
  	@good2 = projects(:two)
  	#@good1.save
  	#@good2.save
  end

  test "should be valid" do
  	assert @good1.valid?
  end

  test "name must be present" do
  	@good1.name = "     "
    assert_not @good1.valid?
  end

  test "amount must be present" do
  	@good1.target_amount = ""
    assert_not @good1.valid?
  end

  test "name should not be too long" do
  	@good1.name = "a" * 21
    assert_not @good1.valid?
  end

  test "name should not be too short" do
  	@good1.name = "a" * 3
    assert_not @good1.valid?
  end

  test "name allows underscores and dashes" do
  	@good1.name = "b-la_h"
  	assert @good2.valid?
  end

  test "amount should be positive" do
  	@good1.target_amount = 0
    assert_not @good1.valid?
    @good1.target_amount = -1
    assert_not @good1.valid?
  end

  test "amount accepts dollars and cents" do
  	@good1.target_amount = 100
    assert @good1.valid?
    @good1.target_amount = 100.50
    assert @good1.valid?
  end

  test "amount does not accept dollar signs" do
  	# amount must be a numeric value
  	@good1.target_amount = "$100"
    assert_not @good1.valid?
  end

end
