#!/usr/bin/ruby
require 'infinite_glitch'

puts "TESTS: GET_INTERNET_ARCHIVE: RESULTS:"

p = Parser.new
urls = p.parse_internet_archive_search
results = p.parse_internet_archive(urls[0])
if results == false
  puts "No acceptable media files found"
else
  g = Grabber.new
  puts "TESTS: GET_INTERNET_ARCHIVE: DOWNLOAD: #{results[:url]}"
  puts "TESTS: GET_INTERNET_ARCHIVE: SIZE: #{results[:size]}"
  g.download(results[:url])
end

puts "TESTS: GET_INTERNET_ARCHIVE: COMPLETED"
