module TimezoneFu
  
  module ActMethods
    def has_timezone(options = {})
      unless included_modules.include?(TZInstanceMethods)
        include TZInstanceMethods
        
        options[:time_format] ||= '%b. %d, %Y %I:%M %p'
        options[:default_timezone] ||= TZInfo::Timezone.get('America/Los_Angeles')
        options[:fields] ||= []
        
        class_inheritable_accessor :default_tz
        self.default_tz = options[:default_timezone]
        
        add_date_time_methods(options[:fields], options[:time_format])
        
      end
    end
    protected
      def add_date_time_methods(fields, time_format)
        fields.each do |date_time|
          # def date_time getter
          self.send :define_method, date_time do
            dt = read_attribute(date_time)
            if dt.nil?
              dt              
            else
              get_local_date_time(self.tz, dt)
            end
          end
          # def date_time=(time_val) setter
          self.send :define_method, "#{date_time}=" do |time_val|
              write_attribute(date_time, get_utc_date_time(self.tz, string_to_time(time_val)))
          end
          #  display time
          self.send :define_method, "display_#{date_time}" do
            dt = self.send(date_time) 
            self.send(date_time).strftime(time_format) unless dt.nil?
          end
          self.send :define_method, "utc_#{date_time}" do
            read_attribute(date_time)
          end
        end
      end
  end
  module TZInstanceMethods
    
    def get_local_date_time(timezone, utc_datetime)
      timezone.utc_to_local(utc_datetime)
    end
    
    def get_utc_date_time(timezone, local_datetime)
      timezone.local_to_utc(local_datetime)
    end
    
    # Defaults timezone to Los_Angeles if it has not been set.
    def timezone
      self.tz.name
    end    
    def tz
      this_tz = read_attribute(:timezone)
      return self.default_tz if this_tz.nil?
      
      if not this_tz.empty?
        TZInfo::Timezone.get(this_tz)
      else
        self.default_tz
      end
    end
    protected
      def string_to_time(datetime)
        return datetime unless datetime.is_a?(String)
        Time.parse(datetime)
      end
  end  
end