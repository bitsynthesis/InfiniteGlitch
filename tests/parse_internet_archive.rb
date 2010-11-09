#!/usr/bin/ruby
require 'infinite_glitch'

puts "TESTS: PARSE_INTERNET_ARCHIVE: RESULTS:"

p = Parser.new
urls = p.parse_internet_archive_search
results = p.parse_internet_archive(urls[0])
puts results
