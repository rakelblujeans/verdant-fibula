# Encapsulates the idea of a "kickstarter"
class Project < ActiveRecord::Base
	has_many :contributions
	before_save :trim_name

	# full title of project
	validates :name, presence: true, length: {minimum:4, maximum: 20}
	# target amount of fundraising desired. must be a positive number
	validates :target_amount, presence: true, numericality: { only_integer: false, greater_than: 0 }

	def remaining_amount
		total = 0
		contributions.each do |c|
			total = total + c.amount
		end

		target_amount - total
	end

	def has_met_goal?
		remaining_amount <= 0
	end

	# **2.** The `back` input will back a project with a given name of the
	# backer, the project to be backed, a credit card number and a backing
	# dollar amount.
	def self.back(project_name, backer_name, credit_card_num, amount)
		project = Project.find_by(name: project_name)
		if !project
			puts "Error: project [#{project_name}] not found"
			return nil
		end

		if backer_name.blank?
			puts "Error: backer name cannot be blank"
			return nil
		end
		backer = Backer.find_or_create_by(full_name: backer_name)

		contribution = Contribution.create({
			backer: backer,
			project: project,
			credit_card_num: credit_card_num,
			amount: amount
			})
		
		if contribution.save
			return contribution
		else
			puts contribution.errors.messages
			return nil
		end
	end

	def self.contribution_details(project_name)

		project = Project.find_by(name: project_name)
		if !project
			return "Error: project [#{project_name}] not found"
		end

		output = ""
		project.contributions.each do |c|
			output = output + "#{c.backer.full_name} backed for #{number_to_currency(c.amount)}\n"
		end

		if project.has_met_goal?
			output = output + "#{project.name} is successful!"
		else
			output = output + "#{project.name} needs #{number_to_currency(project.remaining_amount)} more dollars to be successful"
		end

		output
	end

	private

		def trim_name
			# remove all extraneous whitespace
			self.name = name.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
		end
end
