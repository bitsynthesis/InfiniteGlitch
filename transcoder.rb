#!/usr/bin/ruby

class Transcode

  def self.in(filename)
    cmd = "ffmpeg -y -i #{Settings.new.loc_vin}#{filename} #{Settings.new.par_vin[0]} #{Settings.new.loc_vout}#{filename}.#{Settings.new.para_vin[1]}"
    $ig_logger.debug = "TRANSCODE: TRANS_IN: COMMAND: #{cmd}"
    system cmd
    return "#{filename}.#{Settings.new.para_vin[1]}"
  end

  def self.out(filename)
    cmd = "ffmpeg -y -i #{Settings.new.loc_vout}#{filename} #{Settings.new.par_vout[0]} #{Settings.new.loc_play}#{filename}.#{Settings.new.para_vout[1]}"
    $ig_logger.debug = "TRANSCODE: TRANS_OUT: COMMAND: #{cmd}"
    system cmd
    return "#{filename}.#{Settings.new.para_vout[1]}"
  end

end
