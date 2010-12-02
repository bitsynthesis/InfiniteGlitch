#!/usr/bin/ruby
require 'rubygems'
require 'net/http'
require 'open-uri'
require 'nokogiri'

class Internet_Archive < Collector

  # randomize the search page (no arguments)
  def self.find
    id = nil
    page = 1
    browse1 = "http://www.archive.org/advancedsearch.php?q=movies&fl[]=identifier&fl[]=mediatype&fl[]=title&sort[]=&sort[]=&sort[]=&rows=1&page="
    browse2 = "&callback=callback&output=xml"
    data = open("#{browse1}#{page}#{browse2}")
    doc = Nokogiri::HTML(data)
    results = doc.xpath('//result').first['numfound'].to_i
    $ig_logger.debug "COLLECTOR: INTERNET_ARCHIVE: RESULTS: #{results}"
    while id == nil do
      page = rand(results) + 1
      data = open("#{browse1}#{page}#{browse2}")
      doc = Nokogiri::HTML(data)
      type = doc.xpath('//str[@name="mediatype"]')[0].content
      $ig_logger.debug "COLLECTOR: INTERNET_ARCHIVE: TYPE: #{type}"
      if type == "movies"
        id = doc.xpath('//str[@name="identifier"]')[0].content
        break
      end
    end
    url = "http://archive.org/details/#{id}"
    $ig_logger.debug "COLLECTOR: INTERNET_ARCHIVE: URL: #{url}"
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
     if Config.formats.include?(e[:ext].to_s)
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

end
