require 'optparse'
include ActionView::Helpers::NumberHelper
desc "Parses commandline options specified by Kickstarter's coding test"
task :kickstarter => :environment do

	class ParseInput

		def print_errors(obj)
			puts "Fix these errors, then try again:"
			obj.errors.messages.each do |k,v|
				puts "\t#{k.to_s.humanize} #{v[0]}"
			end 
		end

		def check_args(param_names_list, args)
			for i in 0..param_names_list.length-1
				param = param_names_list[i]
				if args[i].blank?
					puts "Fix these errors, then try again:"
					puts "\t#{param.humanize} is missing"
					return false
				# else 
				# 	puts "not blank [#{args[i]}]"
				end
			end

			return true
		end

		def help_msg
			puts "You can use the following commands:"
			puts "\t project <name> <target_amount>"
			puts "\t back <backer_name> <project_name> <credit card num> <backing amount>"
			puts "\t list <project_name>"
			puts "\t backer <full_name>"
		end

		# ~~~
		# project <project> <target amount>
		# ~~~

		# * Projects should be alphanumeric and allow underscores or dashes.
		# * Projects should be no shorter than 4 characters but no longer than 20
		#   characters.
		# * Target dollar amounts should accept both dollars and cents.
		# * Target dollar amounts should NOT use the $ currency symbol to avoid issues with shell escaping.
		def project(args)
			return unless check_args(%w[name target_amount], args)

			p = Project.create({name: args[0], target_amount: args[1]})
			if p.save
				puts "Project #{p.name} successfully created with goal of reaching #{number_to_currency(p.target_amount)}"
			else
				print_errors(p)
			end
		end

		# **2.** The `back` input will back a project with a given name of the
		# backer, the project to be backed, a credit card number and a backing
		# dollar amount.

		# ~~~
		# back <given name> <project> <credit card number> <backing amount>
		# ~~~

		# * Given names should be alphanumeric and allow underscores or dashes.
		# * Given names should be no shorter than 4 characters but no longer than
		#   20 characters.
		# * Credit card numbers may vary in length, up to 19 characters.
		# * Credit card numbers will always be numeric.
		# * Card numbers should be validated using Luhn-10.
		# * Cards that fail Luhn-10 will display an error.
		# * Cards that have already been added will display an error.
		# * Backing dollar amounts should accept both dollars and cents.
		# * Backing dollar amounts should NOT use the $ currency symbol to avoid issues with shell escaping.
		def back(args)
			return unless check_args(%w[given_name project_name credit_card_num amount], args)
			
			contribution = Project.back(args[1], args[0], args[2], args[3])
			if !contribution.has_errors?
				puts "Contribution successfully created"
			else
				print_errors(contribution)
			end
		end

		# **3.** The `list` input will display a project including backers and
		# backed amounts.

		# ~~~
		# list <project>
		# ~~~
		def list(args)
			return unless check_args(%w[project_name], args)

			Project.contribution_details(args[0])
		end

		# **4.** The `backer` input will display a list of projects that a backer
		# has backed and the amounts backed.

		# ~~~
		# backer <given name>
		# ~~~
		def backer(args)
			return unless check_args(%w[backer_name], args)
			Backer.history(args[0])
		end

		def split_params(text)
			# cap the maximum length of the string we want to parse
			# for security reasons
			max_len = 250
			text = text[0..250]

			# check if someone passed in a quoted string as a param
			# if so, count that text as 1 param
			num_quotes = text.scan(/"/).length
			if num_quotes > 0 && num_quotes.odd?
				puts "Error: malformed string"
				return
			end

			i = 0
			terms = []
			loops = 0
			while i < text.length-1
				space_idx = text.index(' ', i)
				quote_idx = text.index('"', i)
				#puts "[#{space_idx} #{quote_idx}]------------"

				# check bounds on indexes
				space_idx = text.length if !space_idx
				quote_idx = text.length if !quote_idx
				#puts "#{space_idx} -- #{quote_idx}"
				
				# if the next delimiter is a space, then treat this as a
				# 1 word term
				if space_idx < quote_idx
					#puts "found space #{text[i]} #{text[i, space_idx-i]}"
					terms << text[i, space_idx-i]
					i = space_idx+1
					#puts "i is now #{i}"
				# if the next delimiter is a quote, scan ahead to the next quote
				# include all that as one term
				elsif space_idx > quote_idx
					#puts "found quote"
					quote_idx2 = text.index('"', quote_idx+1)
					if quote_idx2 > text.length-1
						quote_idx2 = text.length-1
					end
					terms << text[i+1, quote_idx2-quote_idx-1]
					#puts "term was #{text[i]} [#{text[i, quote_idx2-quote_idx]}]"
					i = quote_idx2+2
					#puts "i is now #{i}"
				else
					terms << text[i, text.length-1]
					i = text.length
				end

				if loops > 10
					break
				end
				loops = loops + 1
			end

			terms.each {|t| t.strip!}
			#puts "got terms #{terms.inspect}"
			terms
		end

	end
	
	parser = ParseInput.new
	puts "Welcome! Go ahead, try out a command or two. If you need help, just type 'help' to view all commands."
	
	option = ""
	while option != "exit"
		option = STDIN.gets.chomp
		words = parser.split_params(option)
		puts words.inspect
		
		if words.empty? || words[0].empty?
			parser.help_msg
		else
			# start parse
			case words[0]
			when "project"
				parser.project(words[1, 2])
			when "back"
				parser.back(words[1, 4])
			when "list"
				parser.list(words[1])
			when "backer"
				parser.backer(words[1])
			else
				parser.help_msg
			end
		end
	end
	puts "Goodbye!"
end
