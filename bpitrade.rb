class Bpitrade
	attr_accessor :main_page
	def initialize
		@logged_in = false
	end

	def login
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
		@main_page = mechanize.get("https://www.bpitrade.com/trading/Trading_StockPosition.asp")

		if(@main_page.parser.css('.c4').text.include?("BUYING POWER"))
			@logged_in = true
		end
		@logged_in
	end

	def show_portfolio
		list = @main_page.parser.css("ul#SpDataItemList li")
		pfvalues = @main_page.parser.css("div.pfvalues")

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

		self.render_portfolio(portfolio)
	end

	def quote(stock)
		url = Config::quotes_api_call(stock) # XML response endpoint
		table_header = ['#BIDS', 'BID VOL', 'BID PRICE', 'ASK PRICE', 'ASK VOL', '#ASK']

		doc = Nokogiri::HTML(URI.open(url))
		if doc.xpath('//errormessage').text.include?('not found')
			puts doc.xpath('//errormessage').text
			return false
		end

		# Stock info 
		stock_name = doc.css('secname').text
		last_price = doc.css('last').text
		diff = doc.css('diff').text
		change = doc.css('change').text
		prev_close = doc.css('prevclose').text
		open_price = doc.css('open').text 
		high = doc.css('high').text
		low = doc.css('low').text
		volume = doc.css('volume').first.text
		value = doc.css('value').text
		wk52_high = doc.css('wikhi52').text
		wk52_low = doc.css('wiklo52').text
		status = doc.css('status').text

		# Bid
		orders = doc.xpath('//security//bid//orders')
		bid_vol = doc.xpath('//security//bid//vol')
		price = doc.xpath('//security//bid//price')

		# Ask
		ask_prices = doc.xpath('//security//ask//price')
		ask_vol = doc.xpath('//security//ask/vol')
		ask_orders = doc.xpath('//security//ask//orders')

		table = Terminal::Table.new :headings => table_header do |t|
			orders.each_with_index do |order, index|
				tmp_array = [ order.text, bid_vol[index].text, price[index].text, 
											ask_prices[index].text, ask_vol[index].text, ask_orders[index].text ]
				t << tmp_array
			end
		end

		puts "\n"
		puts "[#{stock.upcase}] #{stock_name} #{last_price} #{change}"
		puts ""
		puts table
		puts ""
		puts "Last: #{last_price} Change: #{change} Prev: #{prev_close} Diff: #{diff}"
		puts "H: #{wk52_high} L: #{wk52_low} Vol: #{volume} Value: #{value}"
		
		
	end

	private

	# handles the display / output of the portfolio
	def render_portfolio(portfolio)
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
	end
end