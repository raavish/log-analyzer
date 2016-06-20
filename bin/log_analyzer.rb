#!/usr/bin/env ruby
require 'date'
require 'pp'
require 'optparse'

class LogAnalyzer

  @@operating_systems = [
    "Windows 95",
    "Windows 98",
    "Windows NT 5.1",
    "Windows NT 5.2",
    "Windows NT 6.1",
    "Windows NT",
    "Linux",
    "Mac OS X"

  ]

  # Reads the log file and parse each record
  def parse_log_events(log_file, pattern)
    parsed_array = []
    begin
      File.open(log_file) do | file |
        # for each line
        file.each do |line|
          row = line.to_s
          row.chomp!
          row.strip!

          # using regex pattern split each line into array of elements
          parsed_row = pattern.match(row)
          unless parsed_row.nil?
            parsed_array << parsed_row.captures
          end
        end
      end
      return parsed_array
    rescue Errno::ENOENT => e
      puts "Unable to open the log file (#{log_file}). Verify file location and permissions.\n #{e.message}"
      exit(false)
    end
  end

  # Groups items by day
  def group_items_by_day(parsed_array, date_format)
    parsed_array.group_by { |item|
      begin
        Date.strptime(item[3], "[#{date_format}]").to_s
      rescue ArgumentError
        # Invalid date format. Skip this item
        next
      end
    }
  end

  # Prints no of requests by day
  def no_of_requests_by_day(requests_per_day_hash)
    requests_per_day_hash.each { |date, item_list|
      # Invalid dates comes as nil. Skip those items
      next if date == nil
      puts "#{date} -> #{item_list.count}"
    }
  end

  # Prints the top User Angets by day
  def top_user_agents_by_day(requests_per_day_hash, no_of_ua)
    # for each day of records
    requests_per_day_hash.each { |date, item_list|
      # Invalid dates comes as nil. Skip those items
      next if date == nil
      # group records by User Agent
      user_agent_per_day_hash = item_list.group_by { |item| item[8] }
      # replace items list by no of items in the user agent hash
      user_agent_per_day_hash.each { |k,v| user_agent_per_day_hash[k] = v.count }
      # sort by no of items
      top_ua = user_agent_per_day_hash.sort_by { |user_agent, items_count| items_count }.reverse.first no_of_ua
      puts "#{date} =>"
      print "\n\n"
      top_ua.each { |ua|
        puts "  #{ua[0]} -> #{ua[1]}"
      }
    }
  end

  # Prints the ratio of GET's to POST's by OS and Day
  def requests_ratio_by_os_day(requests_per_day_hash)
    # for each day of records
    requests_per_day_hash.each { |date, item_list|
      # Invalid dates comes as nil. Skip those items
      next if date == nil
      puts "  #{date}"
      # group items by OS. OS is embedded in User Agent. Each User Agent has its own format.
      # Search each User Agent with fixed OS names and group them
      items_by_os = item_list.group_by { |item|

        os_group = nil
        @@operating_systems.any? { |os|
          if item[8].include?(os)
            os_group = os
          end
        }
        os_group
      }
      # iterate through each os and the item list
      items_by_os.each { |os, sub_item_list|
        # os not listed in the operating_systems array will come as nil.
        next if os == nil
        # group items by http method
        http_method_hash = sub_item_list.group_by { |item| item[4].split[0] }
        # replace items list by no of items in the http method hash
        http_method_hash.each { |k,v| http_method_hash[k] = v.count }
        available_methods = http_method_hash.keys
        # skip the os which has zero items for GET/POST
        if available_methods.include?("GET") && available_methods.include?("POST")
          begin
            # no of GET requests to POST requests ratio
            ratio = Rational(http_method_hash["GET"], http_method_hash["POST"])
            puts "    #{os} -> #{ratio}"
          rescue ZeroDivisionError => e
            puts "ERROR: No of GET/POST requests for the day (#{date}) is 0. Can't calculate ratio for this day."
          end
        else
          # puts "No of GET/POST requests for the os (#{os}) doesn't exists"
        end

      }
    }
  end
end
