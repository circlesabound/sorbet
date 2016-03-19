require_relative "../lib/Exchange.rb"

puts "hi"
ex = Exchange.connect("development_sandbox")
puts "hi"
while !ex.open?
end
