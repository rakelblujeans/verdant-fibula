class Backer < ActiveRecord::Base
	has_many :contributions
	before_save :trim_name

	# person's given name
	validates :full_name, presence: true, length: {minimum:4, maximum: 20}

	private

		def trim_name
			# remove all extraneous whitespace
			self.full_name = full_name.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
		end
end
