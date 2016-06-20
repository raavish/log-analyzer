require_relative '../bin/log_analyzer'
require 'spec_helper'
require 'yaml'

describe LogAnalyzer do
  before do
    config_data = YAML.load_file('bin/config.yaml')
    @log_analyzer = LogAnalyzer.new
    @valid_log_file = "spec/fixtures/valid.log"
    @invalid_log_file = "spec/fixtures/invalid.log"
    @pattern = config_data['pattern']
    @date_format = config_data['date_format']
    @valid_parsed_array = [["127.0.0.1", "-", "-", "[01/Dec/2011:00:00:11 -0500]", "GET / HTTP/1.0", "304", "266", "-", "Sosospider+(+http://help.soso.com/webspider.htm)"]]
    @invalid_parsed_array = [["127.0.0.1", "-", "-", "[01/De/2011:00:00:11 -0500]", "GET / HTTP/1.0", "304", "266", "-", "Sosospider+(+http://help.soso.com/webspider.htm)"]]
    @valid_group_by_day_hash = {"2011-12-01" => [["127.0.0.1", "-", "-", "[01/Dec/2011:00:00:11 -0500]", "GET / HTTP/1.0", "304", "266", "-", "Sosospider+(+http://help.soso.com/webspider.htm)"]]}
    @invalid_group_by_day_hash = {nil => [["127.0.0.1", "-", "-", "[01/Dec/2011:00:00:11 -0500]", "GET / HTTP/1.0", "304", "266", "-", "Sosospider+(+http://help.soso.com/webspider.htm)"]]}
  end

  it 'should throw an error for invalid file' do
    begin
      @log_analyzer.parse_log_events('no_file_exist', @pattern)
    rescue SystemExit => e
      expect(e.status).to eq(1)
    end
  end

  it 'should return an array with formatted log event' do
    expect(@log_analyzer.parse_log_events(@valid_log_file, @pattern)).to eq @valid_parsed_array
  end

  it 'should return empty array when log format is wrong' do
    expect(@log_analyzer.parse_log_events(@invalid_log_file, @pattern)).to eq []
  end

  it 'should return hash with day as key and items list as value' do
    expect(@log_analyzer.group_items_by_day(@valid_parsed_array, @date_format)).to eq @valid_group_by_day_hash
  end

  it 'should return empty hash' do
    begin
      expect(@log_analyzer.group_items_by_day(@invalid_parsed_array, @date_format)).to eq {}
    rescue ArgumentError => e
    end
  end

  it 'should print date and item count' do
    expect(STDOUT).to receive(:puts).with('2011-12-01 -> 1')
    @log_analyzer.no_of_requests_by_day(@valid_group_by_day_hash)
  end

  it "shouldn't print anything" do
    expect(STDOUT).not_to receive(:puts).with('nil -> 1')
    @log_analyzer.no_of_requests_by_day(@invalid_group_by_day_hash)
  end

  it 'shoudl print date and top user agents' do
    expect(STDOUT).to receive(:puts).with("2011-12-01 =>")
    expect(STDOUT).to receive(:puts).with('  Sosospider+(+http://help.soso.com/webspider.htm) -> 1')
    @log_analyzer.top_user_agents_by_day(@valid_group_by_day_hash, 3)
  end

end
