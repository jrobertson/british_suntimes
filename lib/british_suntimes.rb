#!/usr/bin/env ruby

# file: british_suntimes.rb


require 'geocoder'
require 'chronic_cron'
require 'solareventcalculator'



class BritishSuntimes

  attr_reader :to_h, :bst_start, :bst_end


  def initialize(year= Date.today.year.to_s, location: 'edinburgh')

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

    d1 = ChronicCron.new('last sunday in March at 1am', 
          Time.local(year)).to_date
    d2 = ChronicCron.new('last sunday in October at 2am', 
          Time.local(year)).to_date

    @bst_start, @bst_end = d1, d2

    (d1...d2).to_a.each do |d|
      t1, t2 = times[d.strftime("%d %b")].map {|x| Time.parse(x)}
      t1 += 60 * 60; t2 += 60 * 60
      times[d.strftime("%d %b")] = [t1.strftime("%H:%M"), t2.strftime("%H:%M")]
    end

    @to_h = times  

  end

end


if __FILE__ == $0 then

  h = BritishSuntimes.new.to_h

end
