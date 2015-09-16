# Represents an invididual donation to a kickstarter project
class Contribution < ActiveRecord::Base
	belongs_to :backer
	belongs_to :project
	default_scope { order("created_at DESC") }

	# title of project
	#validates :name, presence: true, length: {minimum:4, maximum: 20}
	# must pass Luhn-10 validation and be unique
	validates :credit_card_num, presence: true, length: {minimum: 4, maximum: 19}, 
		uniqueness: { case_sensitive: false }, numericality: { only_integer: false, greater_than: 0 }
	
	validates :backer, presence: true
	validates :project, presence: true

end
