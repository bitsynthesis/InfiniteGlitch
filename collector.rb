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

  # TODO dont create filename until after redirect
  def self.download(url, filename="")
    # split base and file from url
    parts = URI.split(url)
    base = parts[2].match(/([a-zA-Z0-9]+\.[a-zA-Z]+$)/)[1]
    path = parts[5]
    filename = path.match(/(^.*\/)(.*)/)[2] if filename == ""
    filename = "video#{rand(1000000)}" if filename == ""
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
      return filename
    rescue Exception => e
      $ig_logger.error "#{e.message}"
      $ig_logger.error "COLLECTOR: DOWNLOAD: START: FAILED"
      return false
    end
  end

  def self.run
    url = self.find
    $ig_logger.debug "COLLECTOR: DOWNLOAD: URL: #{url}"
    vin = self.download(self.parse(url)[:url])
    if vin == false
      $ig_logger.error "COLLECTOR: TRANSCODE: NO FILE"
      return false
    end
    status = Transcode.in(vin)
    if status == false
      cmd = "rm ./pool/ready/#{vin}.avi"
      system cmd
      $ig_logger.error "COLLECTOR: TRANSCODE: FAIL"
      return false
    else
      cmd = "rm ./pool/raw/#{vin}"
      system cmd
      $ig_logger.debug "COLLECTOR: TRANSCODE: SUCCESS"
      return true
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
    status = c.run
    if status == false
      # DANGER this makes it difficult to force quit
      $ig_logger.error "COLLECT: RUN: FAILED, TRYING AGAIN"
      Collect.run(c)
    else
      return true
    end
  end

end

# load collectors from ./collectors and store them in :registered_collectors
$ig_logger.debug "COLLECTOR: LOADING COLLECTORS"
Dir[File.join(File.dirname(__FILE__),"./collectors/*.rb")].each do |c|
  load c
end
$ig_logger.debug "COLLECTOR: COLLECTORS LOADED: #{Collector.registered_collectors}"

# put auto scheduling code below
