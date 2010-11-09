#!/usr/bin/ruby

class Transcoder

  def prepare_video(vin)
    vout = vin.match(/(.*[\/+])(.*)/)[2]
    cmd = "ffmpeg -t 0 -i #{vin} -vcodec libxvid -an -g 60 -s 640x480 ./pool_ready/videos/#{vout}"
    system cmd
    return true
  end

  def prepare_image(iin)
    iout = iin.match(/(.*[\/+])(.*)/)[2]
    MAGICK::ImageList.new(iin).resize_to_fill(640,480).write("./pool_ready/images/#{iout}")
    return true
  end

  def finish(vin)

  end

end

class Selector

end

class Combiner

end
