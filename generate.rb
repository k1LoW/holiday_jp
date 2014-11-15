# coding: utf-8
require 'holiday_jp'
require 'pp'

holidays = HolidayJp.between(Date.new(1970, 01, 01), Date.new(2050, 12, 24))

weeks = {
  '日' => 'Sunday',
  '月' => 'Monday',
  '火' => 'Tuesday',
  '水' => 'Wednesday',
  '木' => 'Thursday',
  '金' => 'Friday',
  '土' => 'Saturday',
}

holidays.each do |day|
  puts day.date.to_s + ':'
  puts '  date: ' + day.date.to_s
  puts '  week: ' + day.week.to_s
  puts '  week_en: ' + weeks[day.week]
  puts '  name: ' + day.name.to_s
  puts '  name_en: "' + day.name_en.to_s + '"'
  puts ''
end
