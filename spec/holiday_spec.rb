# -*- coding: utf-8 -*-
require 'spec_helper'
require 'yaml'
require 'json'
require 'httpclient'
require 'date'

context 'Check holidays.yml by finds.jp' do
  before do
    today = Date::today
    start_date = today - 365
    end_date = start_date + 365 * 2

    @holidays = YAML.load_file(File.expand_path('../../holidays.yml', __FILE__))

    client = HTTPClient.new
    @calendar = {}

    start_year = start_date.year
    end_year = end_date.year
    (start_year..end_year).each do | year |
      (1..12).each do | month |
        url = sprintf('http://www.finds.jp/ws/calendar.php?json&t=h&y=%s&m=%s&l=3', year, month)
        result = JSON.parse(client.get_content(url))
        result['result']['day'].each do | d |
          holiday = Date::new(year, month, d['mday']) if d
          @calendar[holiday] = {
            'date' => holiday,
            'name' => d['hname'],
          } if (holiday.between?(start_date, end_date) && d['htype'] != 9)
        end if result['result']['day']
      end
    end

    @span = @holidays.select do |date|
      date.between?(start_date, end_date)
    end

  end

  it "should eq holidays count" do    
    expect(@span.size).to eq @calendar.size
  end

  it "holidays.yml should have date of finds.jp" do
    @calendar.each do |date|
      expect(@span.include? date[0]).to eq true
    end
  end

  it "finds.jp result should have date of holidays.yml" do
    @span.each do |date|
      expect(@calendar.include? date[0]).to eq true
    end
  end

  it "holidays.yml should have holiday in lieu of `Mountain Day1" do
    expect(@holidays.has_key? Date::parse('2019-08-12')).to eq true
    expect(@holidays.has_key? Date::parse('2024-08-12')).to eq true
    expect(@holidays.has_key? Date::parse('2030-08-12')).to eq true
    expect(@holidays.has_key? Date::parse('2041-08-12')).to eq true
    expect(@holidays.has_key? Date::parse('2047-08-12')).to eq true
  end
end
