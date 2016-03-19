class GenericBot
	def initialize(environment)
		@pending_orders = {}
		@successful_orders = {}
		@fair_values = {}
		@agent = agent
		@all_orders = {}
	end

	def run
	#our custom loop
	end

	#return hash
	def convert_order_to_hash
	end

	#return nothign
	def store_successful_orders
	end

	#return nothign
	def store_pending_orders
	end

	#return hash
	def new_order
	end

	#return int
	def pending_order_size
	end

	#return int
	def successful_order_size
	end

	#return hash
	def return_current_inventory
	end

	#return hash
	def get_book_value
	end

	#return nothign
	#puts into hash
	def set_fair_value
	end

	#return int
	def get_fair_value(sec)
	end

	#return percentage
	def percentage_difference(sec)
	end
end
