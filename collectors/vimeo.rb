#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'net/http'
require 'nokogiri'

# TODO works up until download... check redirect?
class Vimeo < Collector

  def self.find
    plist = []
    urls = []
    browse = "http://vimeo.com/tag:video/page:1/sort:newest"
    data = open(browse)
    doc = Nokogiri::HTML(data)
    doc.xpath('//div[@class="pagination"]/ul/li').each do |l|
      plist.push(l)
    end
    plist.reverse!
    if plist[0]['class'] == "arrow"
      page = rand(plist[1].content.to_i)
    else
      page = rand(plist[0].content.to_i)
    end
    browse = "http://vimeo.com/tag:video/page:#{page}/sort:newest"
    data = open(browse)
    doc = Nokogiri::HTML(data)
    doc.xpath('//div[@class="item"]/a').each do |a|
      urls.push(a['href'])
    end
    url = "http://vimeo.com" + urls[rand(urls.length)]
    $ig_logger.debug "COLLECTOR: VIMEO: FIND: URL: #{url}"
    return url
  end

  def self.parse(url)
    @fields = {}
    id = url.match(/^.*\/([0-9]+)/)[1]
    browse = "http://vimeo.com/moogaloop/load/clip:#{id}"
    $ig_logger.debug "COLLECTOR: VIMEO: PARSE: URL: #{browse}"
    data = open(browse)
    doc = Nokogiri::XML(data)
    title = doc.xpath('//caption')[0].content
    sig = doc.xpath('//request_signature')[0].content
    sig_exp = doc.xpath('//request_signature_expires')[0].content
    url2 = "http://vimeo.com/moogaloop/play/clip:#{id}/#{sig}/#{sig_exp}/"
    $ig_logger.debug "COLLECTOR: VIMEO: PARSE: URL2: #{url2}"
    @fields = {:title => title, :url => url2}
    return @fields
  end

end
