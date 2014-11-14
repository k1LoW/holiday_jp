# -*- coding: utf-8 -*-
require 'spec_helper'
require 'yaml'
require 'json'
require 'httpclient'

context 'Check holidays.yml by Google Calendar' do
  before do
    today = Date::today
    start_date = today
    end_date = today + 365

    holidays = YAML.load_file(File.expand_path('../../holidays.yml', __FILE__))
    
    @span = holidays.select do |date|
      date.between?(start_date, end_date)
    end

    url = sprintf('http://www.google.com/calendar/feeds/%s/public/full?alt=json&%s&%s',
                  'japanese__ja%40holiday.calendar.google.com',
                  'start-min=' + start_date.to_s,
                  'start-max=' + end_date.to_s)
    client = HTTPClient.new
    result = JSON.parse(client.get_content(url))
    @calendar = {}
    result['feed']['entry'].each do |entry|
      holiday = Date.strptime(entry['gd$when'][0]['startTime'], "%Y-%m-%d")
      @calendar[holiday] = {
        'date' => holiday
      }
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
