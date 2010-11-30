#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'net/http'
require 'nokogiri'

class Vimeo < Collector

  def self.find
    return id
  end

  def self.parse(id)
    @fields = {}
    url = "http://vimeo.com/moogaloop/load/clip:#{id}"
    data = open(url)
    doc = Nokogiri::XML(data)
    title = doc.xpath('//caption')[0].content
    sig = doc.xpath('//request_signature')[0].content
    sig_exp = doc.xpath('//request_signature_expires')[0].content
    url2 = "http://vimeo.com/moogaloop/play/clip:#{id}/#{sig}/sig_exp/"
    # send url2 to download, must handle redirect
    @fields = {:title => title, :url => url2}
    return @fields
  end

  def self.run
#    self.download(self.parse(self.find)[:url])
    $ig_logger.error "COLLECTOR: VIMEO: NOT READY!"
  end

end
