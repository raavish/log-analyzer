<snippet>
  <content>
# Log Analyzer

Parse the log file and generate reports. Following reports are available

* No of requests served by day
* The 3 most frequent User Agents by day
* Ratio of GET's to POST's by OS by day

Options:

  -f or --file  Log file path. If you don't provide log file path then script will load file from default path (sample.log)
  
  -h or --help  Print this help message

## Usage

Run the program with the following command

```
ruby bin/main.rb
```
Run the program with custom log file location

```
ruby bin/main.rb -f another_log_file.log
```

Run rspec tests

```
rspec spec
```
</content>
</snippet>
