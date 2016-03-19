require_relative "../lib/Exchange.rb"

ex = Exchange.connect("development_sandbox")
while !ex.open?
end
