#!/usr/bin/ruby

# config.rb must be in the root folder
class Settings

  class << self; attr_reader :loc_root, :loc_vin, :loc_vout, :loc_vtmp, :loc_play, :loc_all, :formats, :par_vin, :par_vout end

  # GENERAL
  # root
  @loc_root = "#{File.expand_path(File.dirname(__FILE__))}/"
  # locations
  @loc_vin = "#{@loc_root}pool/raw/"
  @loc_vout = "#{@loc_root}pool/ready/"
  @loc_vtmp = "#{@loc_root}pool/tmp/"
  @loc_play = "#{@loc_root}playlist/videos/"
  @loc_all = [@loc_vin, @loc_vout, @loc_vtmp, @loc_play]
  # accepted formats
  @formats = ["ogv", "mpg", "mpeg", "avi", "mp4", "m4v", "mov", "flv", "f4v", "wmv"]

  # ENCODING PARAMETERS
  # incoming
  @par_vin = ["-vcodec libxvid -vf 'scale=640:480,aspect=4:3' -an -s 640x480 -aspect 4:3 -qscale 3 -g 250", "avi"]
  # outgoing
  @par_vout = ["-vcodec libtheora -vf 'scale=640:480,aspect=4:3' -an -g 30 -s 640x480 -aspect 4:3 -r 20 -b 400k", "ogv"]
  # scan frequency (seconds)
  @tran_scan = 10

  # CONSTRUCTION PARAMETERS
  # maximum segment size (frames)
  @max_seg = 150
  # minimum output size (frames)
  @min_size = 1800
  # number of source videos
  @src_vids = 2

  # POOL MAINTENENCE
  # target pool size (videos)
  @pool_target = 10
  # maximum pool size (MB)
  @pool_size = 5120
  # refresh rate (minutes)
  @pool_refresh = 20

end

# Static settings beyond this point (do not change)

class Utility

  def self.makedir(dir)
    if File.exists?(dir) != true
      cmd = "mkdir #{dir}"
      system cmd
    end
  end

end

Settings.loc_all.each do |l|
  Utility.makedir(l)
end
