#!/usr/bin/ruby

class Transcode

  def self.in(filename)
    cmd = "ffmpeg -y -i #{Settings.loc_vin}#{filename} #{Settings.par_vin[0]} #{Settings.loc_vout}#{filename}.#{Settings.para_vin[1]}"
    $ig_logger.debug = "TRANSCODE: TRANS_IN: COMMAND: #{cmd}"
    system cmd
    return "#{filename}.#{Settings.para_vin[1]}"
  end

  def self.out(filename)
    cmd = "ffmpeg -y -i #{Settings.loc_vout}#{filename} #{Settings.par_vout[0]} #{Settings.loc_play}#{filename}.#{Settings.para_vout[1]}"
    $ig_logger.debug = "TRANSCODE: TRANS_OUT: COMMAND: #{cmd}"
    system cmd
    return "#{filename}.#{Settings.para_vout[1]}"
  end

end
