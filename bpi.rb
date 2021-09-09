require 'mechanize'
require 'nokogiri'
require 'pry'
require 'io/console'
require 'terminal-table'
require 'money'
require 'colorize'
require_relative 'config' # user/password module file
require_relative 'stock'
require_relative 'portfolio'

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

# puts "Welcome to BPI Trade console"
# username = input("Username: ").to_s.strip # very important
# print "Password: "
# password = STDIN.noecho(&:gets).to_s.strip # very important

# Setup your own config module
# See README.md
username = Config::get_username 
password = Config::get_password

mechanize = Mechanize.new
page = mechanize.get("https://www.bpitrade.com/")
form = page.forms.first
form['username'] = username
form['password'] = password
form['page'] = "trading/default.asp"

new_page = form.submit

main = mechanize.get("https://www.bpitrade.com/trading/Trading_StockPosition.asp")
list = main.parser.css("ul#SpDataItemList li")
pfvalues = main.parser.css("div.pfvalues")

portfolio = Portfolio.new
row_present = false

# Portfolio today urealized return
Portfolio.set_today_unrealized(strip_to_float(pfvalues[0].children[3].children.first.text), 
															 pfvalues[0].children[3].children.children.text.strip.delete("()%+").to_f)
# Buying power 
Portfolio.set_buying_power(strip_to_float(pfvalues[0].children[7].text))

# each row
list.each do |li| 
	stock = Stock.new

	if li.children.text.gsub("\u00A0", '').empty?
		row_present = false
	else 
		row_present = true
	end

	# each stock details
	li.children.each_with_index do |child, index|
		if index.odd? && index >= 3
			case index 
				when 3
					stock.symbol = child.children.text.strip
				when 5 
					stock.price = strip_to_float(child.children.text)
				when 7 
					stock.ave = strip_to_float(child.children.text)
				when 9 
					stock.shares = strip_to_float(child.children.text)
				when 11 
					stock.market_value = strip_to_float(child.children.text)
					Portfolio.add_total_market_value(stock.market_value)
				when 13 
					stock.total_cost = strip_to_float(child.children.text)
					Portfolio.add_total_cost(stock.total_cost)
				when 15
					stock.profit_loss = strip_to_float(child.children.text)
					Portfolio.add_total_profit_loss(stock.profit_loss)
				when 17 
					stock.pl = strip_to_float(child.children.text)
			end
		end
	end

	if row_present
		portfolio.stocks.push(stock)
	end
end

puts "\nBPI TRADE PORTFOLIO"
table_header = ['Symbol', 'Price', 'Ave', 'Shares', 'Mkt Value', 'Total Cost', 'P/L', '%P/L']
table = Terminal::Table.new :headings => table_header do |t|
	portfolio.stocks.each do |stock|
		tmp_array = [stock.symbol, 
								 money_format(stock.price), 
								 money_format(stock.ave), 
								 money_format(stock.shares), 
								 money_format(stock.market_value), 
								 money_format(stock.total_cost), 
								 money_format(stock.profit_loss, true), 
								 money_format(stock.pl, true)
								]
	  t << tmp_array
	end
end

# Display table

puts table
puts "Today: #{money_format(Portfolio.get_today_unrealized[0], true)} (#{money_format(Portfolio.get_today_unrealized[1], true)}%)"
puts "Buying power: #{money_format(Portfolio.get_buying_power)}"
puts "Total mkt value: #{money_format(Portfolio.get_total_market_value)}"
puts "Total P/L: #{money_format(Portfolio.get_total_profit_loss, true)}"
puts "Total %P/L: #{money_format(Portfolio.get_total_return, true)} % \n"



