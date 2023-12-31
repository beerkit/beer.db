##
#
#
#
# print todays date
#
# print week number
# print day number
# print weekday (mo,tu,etc)
# print month

require 'date'

puts "today's date is #{Date.today}"

d = Date.today

puts "day:   #{d.day}"
puts "month: #{d.month}"
puts "MONTHNAME: #{Date::MONTHNAMES[d.month]}"
puts "year:  #{d.year}"
puts ""

## sunday is 0
## monday is 1
## tuesday is 2
## wednesday is 3
## thursday is 4
## friday is 5
## saturday is 6

puts "wday:  #{d.wday}"
puts "DAYNAME:  #{Date::DAYNAMES[d.wday]}"
puts "yday:  #{d.yday}"

## NOTE: start w/ 0 (zero)  => thus, add +1
puts "week:  #{d.strftime('%W') }"   ## week starting monday (to sunday)

## Sunday -> Saturday is only American standard. International standard is Monday -> Sunday.
##
## Use %W instead of %U, it uses Monday as the first day of the week.

### check some dates for week

puts "2013-12-31  =>  #{Date.new( 2013,12,31).strftime('%W')}"
puts "2014-01-01  =>  #{Date.new( 2014,1,1).strftime('%W')}"
puts "2014-01-04  =>  #{Date.new( 2014,1,4).strftime('%W')}"
puts "2014-01-05  =>  #{Date.new( 2014,1,5).strftime('%W')}"
puts "2014-01-06  =>  #{Date.new( 2014,1,6).strftime('%W')}"  ## first Monday in year (week 2 ?? - if NOT 1.1. first day of year)

puts "2014-12-31  =>  #{Date.new( 2014,12,31).strftime('%W')}"
puts "2015-01-01  =>  #{Date.new( 2015,1,1).strftime('%W')}"
puts "2015-01-04  =>  #{Date.new( 2015,1,4).strftime('%W')}"
puts "2015-01-05  =>  #{Date.new( 2015,1,5).strftime('%W')}"  ## first Monday in year (week 2 ??)
puts "2015-01-06  =>  #{Date.new( 2015,1,6).strftime('%W')}"



=begin
today's date is 2014-11-04 20:09:12 +0100
day:   4
month: 11
year:  2014

wday:  2
WDAY:  Tuesday
yday:  308
week:  44
=end
