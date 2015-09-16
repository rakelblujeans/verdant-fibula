require 'luhn'
# Represents an invididual donation to a kickstarter project
class Contribution < ActiveRecord::Base
	include ActiveModel::Validations
	belongs_to :backer
	belongs_to :project
	default_scope { order("created_at DESC") }

	class CreditCardValidator < ActiveModel::EachValidator
	 	def validate_each(record, attribute, value)
	 		record.errors.add attribute, (options[:message] || "is not a valid credit card number") unless
	 			Luhn.valid? value
	 			return true
	 	end
	end

	validates :credit_card_num, presence: true, length: {minimum: 4, maximum: 19}, 
		uniqueness: { case_sensitive: false }, numericality: { only_integer: false, 
			greater_than: 0 }, credit_card: true
	
	validates :amount, numericality: { only_integer: false, greater_than: 0 }
	validates :backer, presence: true
	validates :project, presence: true

end