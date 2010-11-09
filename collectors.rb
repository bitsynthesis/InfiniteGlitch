#!/usr/bin/ruby
require 'rubygems'
require 'net/http'
require 'open-uri'
require 'nokogiri'

class Parser

  def initialize
    @image = ["png", "jpg", "jpeg", "gif", "svg"]
    @video = ["ogv", "mpg", "mpeg", "avi", "mp4", "m4v", "mov", "flv", "ogg"]
  end

  def parse_flickr
    @fields = []
    random = rand(10000)
    url = "http://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=#{FLICKR_API_KEY}&extras=url_m,owner_name,description,tags&per_page=50&page=#{random}"
    data = open(url)
    doc = Nokogiri::XML(data)
    doc.xpath('//photos/photo').each do |p|
puts "#{p.path}/@title"
      title = doc.xpath("#{p.path}/@title")[0]
      tags = doc.xpath("#{p.path}/@tags")[0]
      url = doc.xpath("#{p.path}/@url_m")[0]
      width = doc.xpath("#{p.path}/@width_m")[0]
      height = doc.xpath("#{p.path}/@height_m")[0]
      description = doc.xpath("#{p.path}/description")[0].content
      fields_tmp = {:title => title, :tags => tags, :url => url, :width => width, :height => height, :description => description}
      @fields.push(fields_tmp)
    end
    return @fields
  end

  def parse_internet_archive(url)
    @files = []
    @fields = {}
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
    @files.sort_by {|e| e[:size]}.each do |e|
      if @video.include?(e[:ext])
        url = "http://www.archive.org#{e[:link]}"
        break
      end
    end
    @fields = {:title => title, :description => description, :url => url}
  end

  def parse_internet_archive_search(query=false, page=1)
    if query == false
      url = 'http://www.archive.org/search.php?sort=-publicdate&query=%28mediatype%3A%28MovingImage%29%29%20AND%20%28format%3Ampeg%20OR%20format%3Aquicktime%20OR%20format%3Areal%29&page=' + "#{page}"
    else
      url = "http://www.archive.org/search.php?query=#{query}"
    end
    data = open(url)
    doc = Nokogiri::HTML(data)
    urls = []
    doc.xpath('//a[@class="titleLink"]/@href').each {|u| urls.push("http://www.archive.org#{u}")}
    return urls
  end
  
  def parse_wikimedia(url="http://commons.wikimedia.org/wiki/Special:Random/File")
    data = open(url, "User-Agent" => "Ruby/#{RUBY_VERSION}")
    doc = Nokogiri::HTML(data)
    ext = doc.xpath('//title')[0].content.match(/[a-z]+(?= - Wikimedia Commons$)/)[0]
#    $ig_logger.debug "COLLECTORS: PARSER: PARSE_WIKIMEDIA: EXT: #{ext}"
    if @image.include?(ext)
      return self.parse_wikimedia_image(doc)
    elsif @video.include?(ext)
      return self.parse_wikimedia_video(doc)
    else
#      $ig_logger.error "COLLECTORS: PARSER: PARSE_WIKIMEDIA: UNSUPPORTED FILE TYPE: #{ext}"
      return false
    end
  end

  def parse_wikimedia_image(doc)
    url = doc.xpath('//div[@id="file"]/a/img/@src')[0].value
    title = doc.xpath('//div[@id="file"]/a/img/@alt')[0].value.match(/[^File:].*$/)[0]
    width = doc.xpath('//div[@id="file"]/a/img/@width')[0].value
    height = doc.xpath('//div[@id="file"]/a/img/@height')[0].value
    return {:url => url, :title => title, :width => width, :height => height}
  end

  def parse_wikimedia_video(doc)
    url = doc.xpath('//div[@class="fullMedia"]/p/a/@href')[0].value
    title = doc.xpath('//div[@class="fullMedia"]/p/a/@title')[0].value
    return {:url => url, :title => title}
  end

  def parse_wikimedia_gallery(url="http://commons.wikimedia.org/wiki/Special:NewFiles")
    data = open(url, "User-Agent" => "Ruby/#{RUBY_VERSION}")    
    doc = Nokogiri::HTML(data)
    urls = []
    doc.xpath('//div[@class="gallerybox"]/div[@class="gallerytext"]/a[1]/@href').each {|u| urls.push("http://commons.wikimedia.org#{u}")}
    return urls
  end

end

class Grabber

  def download(url)
    # split base and file from url
    parts = URI.split(url)
    base = parts[2]
    path = parts[5]
    begin
      size = Net::HTTP.start(base) do |http|
        response = http.get(path)
        open("./tmp/original.jpg", "wb") do |file|
          file.write(response.body)         
        end
      end
      $ig_logger.debug "COLLECTORS: GRABBER: DOWNLOAD_FILE: SIZE #{size} bytes"
      return true
    rescue Exception => e
      $ig_logger.error "#{e.message}"
      $ig_logger.error "COLLECTORS: GRABBER: DOWNLOAD_FILE: START: FAILED"
      return false
    end
  end

end
