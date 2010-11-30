#!/usr/bin/ruby
require 'rubygems'
require 'log4r'
include Log4r

$ig_logger = Logger.new 'IG'
logfig = {"filename" => "logs/ig.log", "trunc" => false}
$ig_logger.outputters = FileOutputter.new('IG',logfig)
$ig_logger.add(Outputter.stdout)
