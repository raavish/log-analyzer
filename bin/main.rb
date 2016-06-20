#!/usr/bin/env ruby
require 'optparse'
require_relative 'log_analyzer'
require 'yaml'

puts <<-HEAD

##########################
#  Analyzing log events  #
##########################
HEAD

help_text =<<HELP

Parse the log file and generate reports. Following reports are available
1 :  No of requests served by day
2 :  The 3 most frequent User Agents by day
3 :  Ratio of GET's to POST's by OS by day

Options:
  -f or --file  Log file path. If you don't provide log file path then script
                will load file from default path (sample.log)
  -h or --help  Print this help message

HELP

config = {}
begin
  config = YAML.load_file('bin/config.yaml')
rescue Errno::ENOENT => e
  print "\nERROR: Unable to open the config file (config.yaml)\n\n"
  exit(false)
end

option = 0
log_file_path = config['log_file_path']
options_text = <<OPTIONS

Select one option below:

   1 :  No of requests served by day
   2 :  The 3 most frequent User Agents by day
   3 :  Ratio of GET's to POST's by OS by day
   4 :  Exit

Run 'ruby bin/main.rb -h' for more information.

OPTIONS

options = {:file => nil}
parser = OptionParser.new do|opts|

  opts.on('-f', '--file file', 'Log File Path') do |file|
          options[:file] = file;
  end

	opts.on('-h', '--help', Integer, 'Displays Help') do
		puts  help_text
		exit(true)
	end
end

parser.parse!

if !options[:file].nil? && !options[:file].chomp.empty?
    log_file_path = options[:file]
else
  puts "\nUsing default log file path: #{log_file_path}"
end

date_format = config['date_format']
pattern = config['pattern']

log_analyzer = LogAnalyzer. new
parsed_array = log_analyzer.parse_log_events(log_file_path, pattern)
requests_per_day_hash = log_analyzer.group_items_by_day(parsed_array, date_format)

while true

  puts options_text
  print 'Enter Option: '
    option = gets.chomp

  case option
  when "1"
    print "\nNo of requests served by day: \n\n"
    log_analyzer.no_of_requests_by_day(requests_per_day_hash)
  when "2"
    print "\nThe 3 most frequent User Agents by day: \n\n"
    log_analyzer.top_user_agents_by_day(requests_per_day_hash, 3)
  when "3"
    print "\nRatio of GET's to POST's by OS by day: \n\n"
    log_analyzer.requests_ratio_by_os_day(requests_per_day_hash)
  when "4"
    print "\nExit!\n\n"
    exit
  else
    print "\nInvalid option #{option}\n"
    next
  end
  print "\nPress ENTER to continue\n"
  gets
end
