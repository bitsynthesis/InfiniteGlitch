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

  def remove_keys(vin)
    cmd = "datamosh #{vin}"
    system cmd
  end

  def finish(vin)

  end

end

class Selector

end

class Combiner

  def open(vin)
    @@ag = AviGlitch.open vin
    @@delta = []
    @@key = []
    @@ag.frames.each_with_index do |f, i|
      if f.is_deltaframe?
        @@delta.push(i)
      else
        @@key.push(i)
      end
    end
    @@q = @@ag.frames[0, 5]
    return true
  end

  def add_key
    x = @@ag.frames[@@key[rand(@@key.size)], 1]
    @@q.concat(x)
    return true 
  end

  def slip
    start = rand(@@delta.size)
    stop = rand(@@delta.size - start)
    x = @@ag.frames[@@delta[start], stop]
    @@q.concat(x)
    return true
  end

  def slide
    x = @@ag.frames[@@delta[rand(@@delta.size)], 1]
    @@q.concat(x * rand(60))
    return true
  end

  def finalize(vout)
    og = AviGlitch.open @@q
    og.output "./tmp/sections/#{vout}"
  end

end
