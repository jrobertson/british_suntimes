#!/usr/bin/env ruby

# file: british_suntimes.rb


require 'dynarex'
require 'geocoder'
require 'chronic_cron'
require 'solareventcalculator'

require 'subunit'
require 'human_speakable'



class BritishSuntimes

  attr_reader :to_h, :bst_start, :bst_end, :to_dx, :longest_day, :shortest_day


  def initialize(year=Date.today.year.to_s, location: 'edinburgh',
                 debug: false)

    @location, @debug = location, debug

    a = (Date.parse(year + ' Jan')...Date.parse(year.succ + ' Jan')).to_a
    g = Geocoder.search(location)

    puts 'finding the times ...' if @debug
    times = a.inject({}) do |r, date|

      calc = SolarEventCalculator.new(date, *g[0].coordinates)

      a2 = %w(sunrise sunset).map do |event|
        calc.method('compute_utc_official_'.+(event).to_sym).call\
          .strftime("%H:%M")
      end

      r.merge(date.strftime("%d %b") => a2)
    end

    # alter the times for British summertime

    @bst_start = ChronicCron.new('last sunday in March at 1am',
          Time.local(year)).to_date
    @bst_end = ChronicCron.new('last sunday in October at 2am',
          Time.local(year)).to_date


    (@bst_start...@bst_end).to_a.each do |d|
      t1, t2 = times[d.strftime("%d %b")].map {|x| Time.parse(x)}
      t1 += 60 * 60; t2 += 60 * 60
      times[d.strftime("%d %b")] = [t1.strftime("%H:%M"), t2.strftime("%H:%M")]
    end

    @year, @location, @to_h = year, location, times
    puts 'buklding @to_dx' if @debug
    @to_dx = build_dx()

  end

  # exports the sun times to a raw Dynarex file
  #
  def export(filename=@location + "-suntimes-#{@year}.txt")
    File.write filename, @to_dx.to_s
  end

  private

  def build_dx()

    dx = Dynarex.new 'times[title, tags, desc, bst_start, ' +
        'bst_end, longest_day, shortest_day]/day(date, sunrise, sunset)'
    dx.title = @location + " sunrise sunset times " + @year
    dx.tags = @location + " times sunrise sunset %s" % [@year]
    dx.delimiter = ' # '
    dx.bst_start, dx.bst_end = @bst_start.to_s, @bst_end.to_s
    dx.desc = 'Adjusted for British summertime'

    @to_h.each {|k,v| dx.create({date: k, sunrise: v[0], sunset: v[1]}) }

    a = dx.all.map do |x|
      Time.parse(x.date + ' ' + x.sunset) - Time.parse(x.date + ' ' + x.sunrise)
    end

    shortest, longest = a.minmax.map {|x| dx.all[a.index(x)]}
    @longest_day = dx.longest_day = longest.date
    @shortest_day = dx.shortest_day = shortest.date

    dx
  end

end

class BritishSuntimesAgent < BritishSuntimes
  using HumanSpeakable
  using Ordinals


  def longest_day()

    d = super()
    days = (Date.parse(d) - Date.today).to_i
    sunrise, sunset = to_dx().to_h[d]

    t1 = Time.parse(d + ' ' + sunrise)
    t2 = Time.parse(d + ' ' + sunset)

    su = Subunit.new(units={minutes:60, hours:60}, seconds: (t2 - t1).to_i)
    duration = su.to_s omit: [:seconds]

    d2 = Date.parse(d)
    day = d2.strftime("#{d2.day.ordinal} %B")

    s = d2.humanize
    msg =  s[0].upcase + s[1..-1] + ", the longest day of the year, #%s \
will enjoy %s of sunshine. The sun will rise at %sam \
and set at %spm." % [@location, duration, t1.strftime("%-I:%M"), \
                             t2.strftime("%-I:%M")]

  end

end


if __FILE__ == $0 then

  h = BritishSuntimes.new.to_h

end
