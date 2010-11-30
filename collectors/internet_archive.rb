#!/usr/bin/ruby
require 'rubygems'
require 'net/http'
require 'open-uri'
require 'nokogiri'

class Internet_Archive < Collector

  # randomize the search page (no arguments)
  def self.find(query=false, page=1)
    if query == false
      url = 'http://www.archive.org/search.php?sort=-publicdate&query=%28mediatype%3A%28MovingImage%29%29%20AND%20%28format%3Ampeg%20OR%20format%3Aquicktime%20OR%20format%3Areal%29&page=' + "#{page}"
    else
      url = "http://www.archive.org/search.php?query=#{query}"
    end
    data = open(url)
    doc = Nokogiri::HTML(data)
    urls = []
    doc.xpath('//a[@class="titleLink"]/@href').each {|u| urls.push("http://www.archive.org#{u}")}
    url = urls[rand(urls.length)]
    $ig_logger.debug "COLLECTOR: INTERNET_ARCHIVE: FIND: #{url}"
    return url
  end

  def self.parse(url)
    @files = []
    @fields = {}
    found = false
    data = open(url)
    doc = Nokogiri::HTML(data)
    # title not properly parsed, needs regex
    title = doc.xpath('//title')[0].content
    description = doc.xpath('//meta[@name="description"]/@content')[0].value
    # could also pull tags from keywords
    doc.xpath('//table[@class="fileFormats"]/tr/td/a').each do |a|
      link = doc.xpath("#{a.path}/@href")[0].value
      ext = doc.xpath("#{a.path}/@href")[0].value.match(/[a-z]+(?=$)/)
      # convert all file sizes to bytes
      size_string = doc.xpath("#{a.path}")[0].content
      size_string = size_string.match(/([\d.]+)\s?(KB|MB|GB)/)
      next if size_string == nil
      if size_string[2] == "GB"
        size = size_string[1].to_f * 1073741824
      elsif size_string[2] == "MB"
        size = size_string[1].to_f * 1048576
      elsif size_string[2] == "KB"
        size = size_string[1].to_f * 1024
      else
        size = size_string[1].to_f
      end
      files_tmp = {:ext => ext, :size => size, :link => link}
      @files.push(files_tmp)
    end
    # determine which is the smallest video file
    filesize = 0
    @files = @files.sort_by {|e| e[:size]}
    @files.each do |e|
     if Collector.formats.include?(e[:ext].to_s)
        url = "http://www.archive.org#{e[:link]}"
        filesize = e[:size].to_i
        found = true
        break
      end
    end
    if found
      @fields = {:title => title, :description => description, :url => url, :size => filesize}
      return @fields
    else
      return false
    end
  end

  def self.run
    self.download(self.parse(self.find)[:url])
  end

end
