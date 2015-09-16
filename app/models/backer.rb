class Backer < ActiveRecord::Base
	has_many :contributions
	before_save :trim_name

	# person's given name
	validates :full_name, presence: true, length: {minimum:4, maximum: 20}

	def self.history(backer_name)
		backer = Backer.find_by(name: backer_name)
		if !backer
			puts "Error: no backer found by that name"
		end

		list = backer.contributions.group_by(&:project_id)
		list.each do |k,v|

		end

	end

	private

		def trim_name
			# remove all extraneous whitespace
			self.full_name = full_name.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
		end
end
