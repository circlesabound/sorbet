require_relative "../lib/Exchange.rb"

ex = Exchange.connect("development_slow")
while !ex.open?
end

loop do
	puts "**************************"
	puts ex.getDetails
	puts "**************************"
	sleep(3)
end
