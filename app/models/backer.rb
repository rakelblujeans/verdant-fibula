class Backer < ActiveRecord::Base
	has_many :contributions
	before_save :trim_name
	default_scope { order("full_name DESC") }

	# person's given name
	validates :full_name, presence: true, length: {minimum:4, maximum: 20}

	def self.history(backer_name)
		backer = Backer.find_by(full_name: backer_name)
		if !backer
			puts "Error: no backer found by that name"
			return
		end

		# NOTE: This is a naive implementation
		# that assumes a backer makes 1 contribution per project.
		# If we wanted, we could group the contributions according to project,
		# and display a list underneath each project name like so:
		# Awesome_Sauce
		#   Backed for $50
		#   Backed for $25
		# Awesomer_Sauce
		#   Backed for $75
		# ... so on...

		list = backer.contributions.each do |c|
			# -- Backed Awesome_Sauce for $50
			puts "Backed #{c.project.name} for #{number_to_currency(c.amount)}"
		end
	end

	private

		def trim_name
			# remove all extraneous whitespace
			self.full_name = full_name.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
		end
end
