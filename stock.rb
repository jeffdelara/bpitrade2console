class Stock
	attr_accessor :symbol, :price, :ave, :shares, :market_value, 
								:total_cost, :profit_loss, :pl 

	def initialize
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

	def self.total_return
		pl = (@@total_profit_loss / @@total_total_cost) * 100
		pl.round(2)
	end
end