# Introducing the british_suntimes gem

    require 'british_suntimes'

    h = BritishSuntimes.new.to_h
    "Today: sunrise: %s sunset: %s" % h[Date.today.strftime('%d %b')]

    #=> Today: sunrise: 06:47 sunset: 18:01

The british_suntimes gem calculates the British (default location is Edinburgh) sunrise and sunset times for the current year.

sunrise sunset suntimes
