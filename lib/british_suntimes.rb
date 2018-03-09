#!/usr/bin/env ruby

# file: british_suntimes.rb


require 'dynarex'
require 'geocoder'
require 'chronic_cron'
require 'solareventcalculator'



class BritishSuntimes

  attr_reader :to_h, :bst_start, :bst_end, :to_dx


  def initialize(year=Date.today.year.to_s, location: 'edinburgh')

    a = (Date.parse(year + ' Jan')...Date.parse(year.succ + ' Jan')).to_a
    g = Geocoder.search(location)

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
        'bst_end]/day(date, sunrise, sunset)'
    dx.title = @location + " sunrise sunset times " + @year
    dx.tags = @location + " times sunrise sunset %s" % [@year]
    dx.delimiter = ' # '
    dx.bst_start, dx.bst_end = @bst_start.to_s, @bst_end.to_s
    dx.desc = 'Adjusted for British summertime'

    @to_h.each {|k,v| dx.create date: k, sunrise: v[0], sunset: v[1] }     
    
    dx
  end  

end


if __FILE__ == $0 then

  h = BritishSuntimes.new.to_h

end
