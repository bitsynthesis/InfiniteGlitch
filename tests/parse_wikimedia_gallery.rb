#!/usr/bin/ruby
require "infinite_glitch"

p = Parser.new

results = p.parse_wikimedia_gallery

puts "TESTS: WIKIMEDIA_GALLERY: RESULTS:"
x = 1
results.each do |v|
  puts "url #{x}: #{v}"
  x += 1
end