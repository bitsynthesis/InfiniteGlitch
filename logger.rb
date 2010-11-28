#!/usr/bin/ruby

$ig_logger = Logger.new 'IG'
logfig = {"filename" => "logs/ig.log", "trunc" => false}
$ig_logger.outputters = FileOutputter.new('IG',logfig)
$ig_logger.add(Outputter.stdout)


