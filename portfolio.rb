class Portfolio
	attr_accessor :stocks
	@@total_total_cost = 0.0 
	@@total_market_value = 0.0 
	@@total_profit_loss = 0.0
	@@unrealized_today = 0.0
	@@unrealized_today_percent = 0.0
	@@buying_power = 0.0

	def initialize
		@stocks = []
	end

	def display
	end

	def self.add_total_cost(total_cost)
		@@total_total_cost = @@total_total_cost + total_cost
	end

	def self.add_total_market_value(market_value)
		@@total_market_value += market_value
	end

	def self.add_total_profit_loss(profit_loss)
		@@total_profit_loss += profit_loss
	end

	def self.get_total_cost 
		@@total_total_cost.round(2)
	end

	def self.get_total_market_value
		@@total_market_value.round(2)
	end

	def self.get_total_profit_loss
		@@total_profit_loss.round(2)
	end

	def self.get_total_return
		pl = (@@total_profit_loss / @@total_total_cost) * 100
		pl.round(2)
	end

	def self.set_today_unrealized(unrealized, percent)
		@@unrealized_today = unrealized
		@@unrealized_today_percent = percent
	end

	def self.get_today_unrealized
		[@@unrealized_today, @@unrealized_today_percent]
	end

	def self.set_buying_power(buying_power)
		@@buying_power = buying_power
	end

	def self.get_buying_power
		@@buying_power
	end
end