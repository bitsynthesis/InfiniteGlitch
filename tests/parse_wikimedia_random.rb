#!/usr/bin/ruby
require "infinite_glitch"

p = Parser.new

results = p.parse_wikimedia

puts "TESTS: WIKIMEDIA_RANDOM: RESULTS:"
results.each {|k,v| puts "#{k}: #{v}"}