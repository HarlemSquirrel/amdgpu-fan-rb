# frozen_string_literal: true

module AmdgpuFan
  # A mixin to help with CLI output formatting
  module CliOutputFormat
    METER_CHAR = '*'
    TIME_FORMAT = '%F %T'

    private

    def current_time
      Time.now.strftime(TIME_FORMAT)
    end

    def percent_meter(percent, length = 10)
      progress_bar_count = (length * percent.to_f / 100).round
      percent_string = "#{percent}%".ljust(4)
      "[#{METER_CHAR * progress_bar_count}#{' ' * (length - progress_bar_count)}]#{percent_string}"
    end

    def radeon_logo
      File.read(File.join(__dir__, '../../../assets/radeon_r_black_red_100x100.ascii'))
    end
  end
end
