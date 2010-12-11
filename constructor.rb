#!/usr/bin/ruby
require 'rubygems'
require 'aviglitch'

class Constructor

  def initialize
    @clipdata = []
    @first = true
  end

  def open(filename)
    clip = AviGlitch.open(filename)
    pframes = []
    keys = []
    clip.frames.each_with_index do |f, i|
      if f.is_pframe?
        pframes.push(i)
      else
        keys.push(i)
      end
    end
    tmp = {:pframes => pframes, :keys => keys, :clip => clip}
    @clipdata.push(tmp)
    self.add_key
    return true
  end

  def add_key
    num = rand(@clipdata.length)
    clip = @clipdata[num][:clip]
    keys = @clipdata[num][:keys]
    x = clip.frames[keys[rand(keys.size)], 1]
    if @first
      @timeline = x
      @first = false
    else
      @timeline.concat(x)
    end
    return 1
  end

  def slip
    num = rand(@clipdata.length)
    clip = @clipdata[num][:clip]
    pframes = @clipdata[num][:pframes]
    start = rand(pframes.size)
    stop = rand(Settings.max_seg)
    stop = rand(pframes.size - stsart) if stop > (pframes.size - start)
    x = clip.frames[pframes[start], stop]
    y = x.to_avi
    y.glitch :keyframe do |k|
      nil
    end
    @timeline.concat(y.frames)
    return y.frames.size
  end

  def slide
    num = rand(@clipdata.length)
    clip = @clipdata[num][:clip]
    pframes = @clipdata[num][:pframes]
    reps = rand(Settings.max_seg)
    x = clip.frames[pframes[rand(pframes.size)], 1]
    @timeline.concat(x * reps)
    return reps
  end

  def finalize(filename)
    og = AviGlitch.open(@timeline)
    og.output(filename)
    return og.frames.size
  end

end

class Construct

  def self.run
    
  end

end
