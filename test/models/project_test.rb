require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
  	@good1 = projects(:one)
  	@good2 = projects(:two)
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

  test "back handles invalid project gracefully" do
    contribution = Project.back("", "John", "5105105105105100", "500")
    assert_equal nil, contribution
  end

  test "back handles invalid backer gracefully" do
    @good1 = projects(:one)
    @good1.save
    contribution = Project.back(@good1.name, "", "5105105105105100", "500")
    assert_equal nil, contribution
  end

  test "back handles creates new backer gracefully" do
    contribution = Project.back(@good1.name, "Betty", "5105105105105100", "500")
    assert_not_nil contribution
  end

  test "back handles invalid credit card gracefully" do
    @good1 = projects(:one)
    @good1.save
    contribution = Project.back(@good1.name, "John", "1234123412341234", "500")
    assert_equal false, contribution.valid?
  end

  test "back handles invalid amount gracefully" do
    @good1 = projects(:one)
    @good1.save
    contribution = Project.back(@good1.name, "John", "378282246310005", "0")
    assert_equal false, contribution.valid?
  end

  test "back succeeds with valid input" do
    @good1 = projects(:one)
    @good1.save
    contribution = Project.back(@good1.name, "John", "378282246310005", "50")
    assert_not_nil contribution
  end

  test "contribution_details handles invalid project name gracefully" do
    assert_nothing_raised do
      output = Project.contribution_details("")
      assert_match /Error/, output
    end
  end

  test "contribution_details displays list of info" do
    @good1 = projects(:one)
    @good1.save
    Project.back(@good1.name, "John", "378282246310005", "50")
    output = Project.contribution_details(@good1.name)
    assert_no_match /Error/, output
  end

  test "contribution_details displays if project met goal" do
    @good1 = projects(:one)
    @good1.target_amount = 50
    @good1.save
    Project.back(@good1.name, "John", "378282246310005", "51")
    output = Project.contribution_details(@good1.name)
    assert_match /successful/, output
  end

  test "remaining amount returns accurate amount" do
    @good1 = projects(:one)
    @good1.target_amount = 50
    @good1.save
    Project.back(@good1.name, "John", "378734493671000", "25")
    assert_equal 25, @good1.remaining_amount
  end

  test "has_met_goal returns true when goal met" do
    @good1 = projects(:one)
    @good1.target_amount = 50
    @good1.save
    Project.back(@good1.name, "John", "30569309025904", "50")
    assert_equal true, @good1.has_met_goal?
  end

  test "has_met_goal returns false if under target" do
    @good1 = projects(:one)
    @good1.target_amount = 50
    @good1.save
    Project.back(@good1.name, "John", "38520000023237", "49")
    assert_equal false, @good1.has_met_goal?
  end

end