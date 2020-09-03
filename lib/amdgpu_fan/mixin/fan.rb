# frozen_string_literal: true

module AmdgpuFan
  ##
  # A mixin to read fan details and validate input
  module Fan
    private

    def fan_file(type)
      @fan_file ||= {}
      @fan_file[type] ||= "#{base_hwmon_dir}/fan1_#{type}"
    end

    def fan_mode_file
      @fan_mode_file ||= "#{base_hwmon_dir}/pwm1_enable"
    end

    def fan_power_file
      @fan_power_file ||= "#{base_hwmon_dir}/pwm1"
    end

    def fan_speed_raw
      File.read(fan_power_file).strip
    end

    def fan_raw_speeds(type)
      @fan_raw_speeds ||= {}
      @fan_raw_speeds[type] ||= File.read(Dir.glob("#{base_card_dir}/**/pwm1_#{type}").first).to_i
    end

    ##
    # Validate the raw fan speed is between the minimum and maximum values
    # read from sysfs.
    def valid_fan_raw_speed?(raw)
      !raw.nil? && (fan_raw_speeds(:min)..fan_raw_speeds(:max)).cover?(raw.to_i)
    end

    def valid_fan_percent_speed?(percent)
      (1..100.to_i).cover?(percent.to_i)
    end
  end
end
