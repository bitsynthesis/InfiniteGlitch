#!/usr/bin/ruby
require 'net/http'
require 'open-uri'

class Collector

  class << self
    attr_reader :registered_collectors
    attr_reader :formats
  end
    @registered_collectors = []
    @formats = ["ogv", "mpg", "mpeg", "avi", "mp4", "m4v", "mov", "flv"]

  def self.inherited(child)
    Collector.registered_collectors << child
  end

  def self.download(url)
    # split base and file from url
    parts = URI.split(url)
    base = parts[2].match(/([a-zA-Z0-9]+\.[a-zA-Z]+$)/)[1]
    path = parts[5]
    filename = path.match(/(^.*\/)(.*)/)[2]
    begin
      Net::HTTP.get_response URI.parse(url) do |response|
        if response['Location']!=nil
          puts "REDIRECT TO: #{response['Location']}"
          return download(response['Location'])
        end
        raise "No body in http response" if response.body == ''
        open("./pool/raw/#{filename}", "wb") do |file|
          file.write(response.read_body)
        end
      end
      $ig_logger.debug "COLLECTOR: DOWNLOAD: SIZE #{size} bytes"
      return true
    rescue Exception => e
      $ig_logger.error "#{e.message}"
      $ig_logger.error "COLLECTORS: GRABBER: DOWNLOAD_FILE: START: FAILED"
      return false
    end
  end

end

class Collect

  # site may be specified by class name for debugging
  def self.run(site=false)
    if site == false
      c = Collector.registered_collectors[rand(Collector.registered_collectors.length)]
    else
      c = site
    end
    c.run
  end

end

# load collectors from ./collectors and store them in :registered_collectors
$ig_logger.debug "COLLECTOR: LOADING COLLECTORS"
Dir[File.join(File.dirname(__FILE__),"./collectors/*.rb")].each do |c|
  load c
end
$ig_logger.debug "COLLECTOR: COLLECTORS LOADED: #{Collector.registered_collectors}"

# put auto scheduling code below
