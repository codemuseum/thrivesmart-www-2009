require 'timezone_fu'
ActiveRecord::Base.send(:extend, TimezoneFu::ActMethods)