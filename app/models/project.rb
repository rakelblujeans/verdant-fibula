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
	def self.back(project_name, backer_name, credit_card_num, amount)
		project = Project.find_by(name: project_name)
		if !project
			puts "Error: no project found by that name"
		end

		backer = Backer.find_or_create_by!(full_name: backer_name)
		
		contribution = Contribution.create({
			backer: backer,
			project: project,
			credit_card_num: credit_card_num,
			amount: amount
			})
		contribution.save
		return contribution
	end

	def self.contribution_details
		project = Project.find_by(name: project_name)
		if !project
			puts "Error: no project found by that name"
		end

		project.contributions.each do |c|
			puts "[c.created_at] #{c.backer.full_name} contributed #{c.amount}"
		end

	end

	private

		def trim_name
			# remove all extraneous whitespace
			self.name = name.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
		end
end
