# -*- coding: utf-8 -*-
require 'spec_helper'
require 'yaml'
require 'json'
require 'httpclient'
require 'date'
require 'tzinfo'
require 'icalendar'
require 'icalendar/recurrence'

context 'Check holidays.yml by JapanHolidays.ics' do
  before do
    today = Date::today
    start_date = today - 365
    end_date = start_date + 365 * 2

    holidays = YAML.load_file(File.expand_path('../../holidays.yml', __FILE__))

    client = HTTPClient.new
    @calendar = {}
    
    url = 'https://mozorg.cdn.mozilla.net/media/caldata/JapanHolidays.ics'
    result = Icalendar.parse(client.get_content(url), true)
    result.events.each do |event|
      if event.rrule == []
        h = Date.parse(event.dtstart.to_s)       
        @calendar[h] = {
          'date' => h
        } if (h.between?(start_date, end_date))
      else
        event.occurrences_between(start_date, end_date).each do | e |
          h = Date.parse(e.start_time.to_s)
          @calendar[h] = {
            'date' => h
          }
        end
      end
    end

    @span = holidays.select do |date|
      date.between?(start_date, end_date)
    end
  end

  it "should eq holidays count" do    
    expect(@span.size).to eq @calendar.size
  end

  it "holidays.yml should have date of JapanHolidays.ics" do
    @calendar.each do |date|
      expect(@span.include? date[0]).to eq true
    end
  end

  it "JapanHolidays.ics result should have date of holidays.yml" do
    @span.each do |date|
      expect(@calendar.include? date[0]).to eq true
    end
  end
end
