#!/usr/bin/ruby

# config.rb must be in the root folder
class Settings

  attr_reader :loc_root, :loc_vin, :loc_vout, :loc_vtmp, :loc_play, :loc_all, :formats, :par_vin, :par_vout

  def initialize

  # ROOT
  @loc_root = "#{File.expand_path(File.dirname(__FILE__))}/"

  # LOCATIONS
  @loc_vin = "#{@loc_root}pool/raw/"
  @loc_vout = "#{@loc_root}pool/ready/"
  @loc_vtmp = "#{@loc_root}pool/tmp/"
  @loc_play = "#{@loc_root}playlist/videos/"

  @loc_all = [@loc_vin, @loc_vout, @loc_vtmp, @loc_play]

  # ACCEPTED FORMATS
  @formats = ["ogv", "mpg", "mpeg", "avi", "mp4", "m4v", "mov", "flv", "f4v", "wmv"]

  # ENCODING PARAMETERS - INCOMING
  @par_vin = ["-vcodec libxvid -vf 'scale=640:480,aspect=4:3' -an -s 640x480 -aspect 4:3 -qscale 3", "avi"]

  # ENCODING PARAMETERS - OUTGOING
  @par_vout = ["-vcodec libtheora -vf 'scale=640:480,aspect=4:3' -an -g 30 -s 640x480 -aspect 4:3 -b 400k", "ogv"]

  end

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

Settings.new.loc_all.each do |l|
  Utility.makedir(l)
end
