require 'mechanize'
require 'nokogiri'
require 'pry'
require 'open-uri'
require 'io/console'
require 'terminal-table'
require 'money'
require 'colorize'
require_relative 'config' # user/password module file
require_relative 'stock'
require_relative 'portfolio'
require_relative 'bpitrade'

include Config # user/password module file

## Money gem settings
Money.default_currency = "PHP"
I18n.enforce_available_locales = false
Money.locale_backend = :currency
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN

def input(prompt)
	print(prompt)
	$stdout.flush
	gets.chomp
end

def strip_to_float(text)
	text.strip.delete(',').to_f
end

def money_format(money, colorize=false)
	if colorize
		money > 0 ? Money.from_amount(money).format.delete("₱").green : Money.from_amount(money).format.delete("₱").red
	else 
		Money.from_amount(money).format.delete("₱")
	end
end

STATE = {
	INIT: 0,
	LOGGED_IN: 1, 
	MENU: 2,
	SHOW_PORTFOLIO: 3,
	EXIT: 99
}

state = STATE[:INIT]

# Program state
while state != STATE[:EXIT]
	case state
		when STATE[:INIT]
			# INIT
			bpitrade = Bpitrade.new
			result = bpitrade.login()
			
			if result
				state = STATE[:LOGGED_IN]
			else 
				state = STATE[:EXIT]
			end

		when STATE[:LOGGED_IN]
			# You are successfully logged in.
			# SHOW PORTFOLIO
			bpitrade.show_portfolio()
			state = STATE[:MENU]

		when STATE[:QUOTES]
			# QUOTES
			bpitrade = Bpitrade.new
			puts "\nGet price quote for stock."
			stock = input("Enter stock code (q to quit): ").to_s.strip # very important

			if stock == 'q'
				state = STATE[:MENU]
			else
				bpitrade.quote(stock)
			end
			

		when STATE[:MENU]
			# MENU
			puts "\nPick a choice or press any key to exit."
			puts "\n   1. View Portfolio"
			puts "   2. Quotes"
			puts "\n"
			choice = input("Your choice: ").to_s.strip # very important

			case choice.to_i
				when 1
					state = STATE[:INIT]
				when 2
					state = STATE[:QUOTES]
				else 3 
					state = STATE[:EXIT]
			end
	end	
end

puts "Good bye!"
