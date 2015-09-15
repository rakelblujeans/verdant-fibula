# Encapsulates the idea of a "kickstarter"
class Project < ActiveRecord::Base
	has_many :contributions
	before_save :trim_name

	# full title of project
	validates :name, presence: true, length: {minimum:4, maximum: 20}
	# target amount of fundraising desired. must be a positive number
	validates :target_amount, presence: true, numericality: { only_integer: false, greater_than: 0 }

	# **2.** The `back` input will back a project with a given name of the
	# backer, the project to be backed, a credit card number and a backing
	# dollar amount.
	def self.back(project_name, credit_card_num, amount)

	end

	private

		def trim_name
			# remove all extraneous whitespace
			self.name = name.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
		end
end
