# -*- coding: utf-8 -*-
require 'spec_helper'
require 'yaml'
require 'json'
require 'httpclient'

context 'Check holidays.yml by Google Calendar' do
  before do
    today = Date::today
    start_date = today - 365
    end_date = start_date + 365 * 2

    holidays = YAML.load_file(File.expand_path('../../holidays.yml', __FILE__))

    client = HTTPClient.new
    @calendar = {}
    
    url = sprintf('http://www.google.com/calendar/feeds/%s/public/full?alt=json&%s&%s',
                  'japanese__ja%40holiday.calendar.google.com',
                  'start-min=' + start_date.to_s,
                  'start-max=' + (start_date + 365).to_s)
    result = JSON.parse(client.get_content(url))
    result['feed']['entry'].each do |entry|
      holiday = Date.strptime(entry['gd$when'][0]['startTime'], "%Y-%m-%d")
      @calendar[holiday] = {
        'date' => holiday
      }
    end

    url = sprintf('http://www.google.com/calendar/feeds/%s/public/full?alt=json&%s&%s',
                  'japanese__ja%40holiday.calendar.google.com',
                  'start-min=' + (start_date + 365 + 1).to_s,
                  'start-max=' + (start_date + 365 * 2).to_s)
    result = JSON.parse(client.get_content(url))
    result['feed']['entry'].each do |entry|
      holiday = Date.strptime(entry['gd$when'][0]['startTime'], "%Y-%m-%d")
      @calendar[holiday] = {
        'date' => holiday
      }
    end
    
    @span = holidays.select do |date|
      date.between?(start_date, end_date)
    end
  end

  it "should eq holidays count" do    
    expect(@span.size).to eq @calendar.size
  end

  it "holidays.yml should have date of Google Calender's result" do
    @calendar.each do |date|
      expect(@span.include? date[0]).to eq true
    end
  end

  it "Google Calender's result should have date of holidays.yml" do
    @span.each do |date|
      expect(@calendar.include? date[0]).to eq true
    end
  end
end
