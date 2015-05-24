class DateMagic

  MAX_DAY = 31
  MAX_MONTH = 12

  YEAR = 0
  MONTH = 1
  DAY = 2
  HOUR = 3
  MIN = 4

  def self.san_antonio_time time
    time.in_time_zone("Central Time (US & Canada)")
  end

  def self.utc_time time
    (time + 6.hours)
  end

 def self.utc_time_from_str time
    d = ActiveSupport::TimeZone.new('Central Time (US & Canada)').parse(time)
    zone = "Central Time (US & Canada)"  
    d = ActiveSupport::TimeZone[zone].parse(d.to_s)
    d.in_time_zone("UTC")
  end

  def self.sa_to_utc_string string
    zone = "Central Time (US & Canada)"  
    d = ActiveSupport::TimeZone[zone].parse(string)
    d.in_time_zone("UTC").to_s
  end

  def self.build_date_keys start_date, end_date
    start_date = parse_date start_date
    end_date = parse_date end_date
    
    if (start_date[MONTH]==end_date[MONTH]) && (start_date[YEAR] == end_date[YEAR])
      # We differ only by hours or days within `hath month so return that.
      return [{start_date: start_date, end_date: end_date}]
    end

    sets = []
    # First period completes the month
    p = {
      start_date: start_date,
      end_date: [start_date[YEAR],start_date[MONTH], MAX_DAY, end_date[HOUR], end_date[MIN]]
    }
    sets << p
    
    # Check the differences
    if start_date[YEAR] == end_date[YEAR]
      # Second period completes the span up until the month before
      if (((start_date[MONTH]+1)-end_date[MONTH]).abs >= 1) && (start_date[MONTH]!=end_date[MONTH])
        # If same day and just checking hourly differences then just return
        p = { start_date: [start_date[YEAR],start_date[MONTH]+1, 1, start_date[HOUR], start_date[MIN]],
              end_date:  [start_date[YEAR],end_date[MONTH]-1, MAX_DAY, end_date[HOUR], end_date[MIN]]}
        sets << p
      end
      # Remainder of the time
      p = { start_date: [start_date[YEAR],end_date[MONTH], 1, start_date[HOUR], start_date[MIN]],
            end_date:  [start_date[YEAR],end_date[MONTH], end_date[DAY], end_date[HOUR], end_date[MIN]]}
      sets << p
    else
      # We need to make up the remaininder of start year
      p = { start_date: [start_date[YEAR],start_date[MONTH]+1, 1, start_date[HOUR], start_date[MIN]],
            end_date:  [start_date[YEAR],MAX_MONTH, MAX_DAY, end_date[HOUR], end_date[MIN]]}
      sets << p
      # Then for each year add it
      year = start_date[YEAR]+1
      while year!=end_date[YEAR]
        p = { start_date: [year,1, 1, start_date[HOUR], start_date[MIN]],
              end_date:  [year,MAX_MONTH, MAX_DAY, end_date[HOUR], end_date[MIN]]}
        sets << p
        year += 1
      end
      # Check if we need to fill in months
      if (end_date[MONTH]-1).abs >= 1

        p = { start_date: [end_date[YEAR],1, 1, start_date[HOUR], start_date[MIN]],
              end_date:  [end_date[YEAR],end_date[MONTH]-1, MAX_DAY, end_date[HOUR], end_date[MIN]]}
        sets << p
      end
      # Then finish it
      p = { start_date: [end_date[YEAR],end_date[MONTH], 1, start_date[HOUR], start_date[MIN]],
            end_date:  [end_date[YEAR],end_date[MONTH], end_date[DAY], end_date[HOUR], end_date[MIN]]}
      sets << p
    end
    # Return sets of tims
    sets
  end


  def self.parse_date date
    # Parse the date
    d = DateTime.parse(date)
    # Build json for that
    date_array = [d.year, d.month, d.day, d.hour, d.minute]
  end

end
