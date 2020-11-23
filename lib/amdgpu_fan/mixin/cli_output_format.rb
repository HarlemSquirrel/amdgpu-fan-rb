# frozen_string_literal: true

module AmdgpuFan
  # A mixin to help with CLI output formatting
  module CliOutputFormat
    METER_CHARS = [' ', *("\u2588".."\u258F").to_a.reverse].freeze
    TIME_FORMAT = '%F %T'

    def current_time
      Time.now.strftime(TIME_FORMAT)
    end

    ##
    # Return a string with meter and percentage for +percent+
    #
    def percent_meter(percent, width = 3)
      meter_char_indexes = []
      percent_portion_size = 100.0 / width
      width.times do |i|
        current_portion = percent.to_i - (percent_portion_size * i)

        if current_portion >= percent_portion_size
          current_portion_percent = 1
        elsif current_portion <= 0
          current_portion_percent = 0
        else
          current_portion_percent = current_portion / percent_portion_size
        end

        meter_char_indexes << ((METER_CHARS.length - 1) * current_portion_percent.to_f).round
      end

      percent_string = "#{format '%<num>0.2i', num: percent}%".ljust(4)
      "#{percent_string}[#{meter_char_indexes.map { |i| METER_CHARS[i] }.join}]"
    end

    def radeon_logo
      File.read(File.join(__dir__, '../../../assets/radeon_r_black_red_100x100.ascii'))
    end
  end
end
