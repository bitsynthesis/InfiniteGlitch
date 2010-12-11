#!/usr/bin/ruby
require 'ig_logger'
require 'config'
require 'collector'
require 'constructor'
require 'transcoder'

# IG is the timekeeper; the beating heart
class IG

  # beware of conflict w construct for ffmpeg
  # use system scheduler and a global variable
  # to favor construct
  def self.check_vin
    complete = false
    success = false
    Dir.entries(Settings.loc_vin).each do |file|
      Settings.formats.each do |format|
        if file.include?format
          until complete
            if $infinite_glitch_ffmpeg == :free
              $infinite_glitch_ffmpeg = :check_vin
              if Transcode.in(file)
                $infinite_glitch_ffmpeg = :free if $infinite_glitch_ffmpeg == :check_vin
                success = true
              else
                $ig_logger.error "IG.CHECK_VIN.TRANSCODE FAILED"
              end
              cmd = "rm -r #{file}"
              system cmd
              complete = true
            else
              sleep 5
            end
          end
        end
        break if success
      end
    end
  end

  def self.collect
    Collect.run
  end

  def self.construct
    complete = false
    res = Construct.run
    if res != false
      until complete
        $infinite_glitch_ffmpeg = :construct
        Transcode.out(res)
        $infinite_glitch_ffmpeg = :free
        complete = true
      else
        $ig_logger.error "IG.CONSTRUCT.CONSTRUCT FAILED"
      end
    end
  end

end
