require 'test_helper'

class ContributionTest < ActiveSupport::TestCase
  
  def setup
  	@contrib1 = contributions(:one)
  	@backer = backers(:one)
  	@contrib1.backer = @backer
  	@contrib1.project = projects(:one)

  	@contrib_invalid = contributions(:three)
  end

  test "should be valid" do
  	assert @contrib1.valid?
  	assert_not @contrib_invalid.valid?
  end

  test "cc num should not be too long" do
  	@contrib1.credit_card_num = 11
    assert_not @contrib1.valid?
  end

  test "cc num should not be too short" do
  	@contrib1.credit_card_num = 11111111111111111111
    assert_not @contrib1.valid?
  end

  test "cc num should be numeric" do
  	@contrib1.credit_card_num = "111 111"
    assert_not @contrib1.valid?
  end

  test "cc num should be unique" do
  	@contrib1.credit_card_num = 4111111111111111
  	@contrib1.save
    assert @contrib1.valid?

    @contrib_invalid.credit_card_num = 4111111111111111
  	@contrib_invalid.save
    assert_not @contrib_invalid.valid?
  end

  test "cc num needs to pass Luhn validation" do
    @contrib_invalid.credit_card_num = 1234123412341234
    @contrib_invalid.save
    assert_not @contrib_invalid.valid?

    @contrib1.save
    assert @contrib1.valid?
  end

end
