#!/usr/bin/ruby

FLICKR_API_KEY = '864b3fc32f5b148cfa85b7858c9b5c60'

# Do not modify
# Static settings beyond this point
class Utility

  def makedir(dir)
    if File.exists?(dir) != true
      cmd "mkdir #{dir}"
      system cmd
    end
  end

end

util = Utility.new
folders = ["pool", "logs", "data", "tmp", "pool_raw", "./pool_raw/images", "./pool_raw/videos", "pool_ready", "./pool_ready/images", "./pool_ready/videos", "playlist"]
folders.each {|f| util.makedir(f)}
