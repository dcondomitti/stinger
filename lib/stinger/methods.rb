module Stinger
  class Methods
    def self.parse_date_options(options)
      options.each do |k,v|
        options[k] = v.strftime('%Y-%m-%d') if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include?(v.class)
      end

      options
    end
  end
end
