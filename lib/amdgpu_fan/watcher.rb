# frozen_string_literal: true

require 'async'

require_relative 'stat_set'

module AmdgpuFan
  # Keep track of stats over time.
  class Watcher
    attr_reader :core_clock, :fan_speed_rpm, :busy_percent, :num_measurements, :memory_clock,
                :power_draw, :temperature

    def initialize(amdgpu_service)
      @amdgpu_service = amdgpu_service
      @num_measurements = 0

      @core_clock = StatSet.new 'MHz'
      @memory_clock = StatSet.new 'MHz'
      @fan_speed_rpm = StatSet.new 'RPM'
      @busy_percent = StatSet.new '%'
      @power_draw = StatSet.new 'W'
      @temperature = StatSet.new '°C'
    end

    ##
    # Take a new set of measurements and adjust the stats.
    #
    def measure
      @num_measurements += 1

      Async do |task|
        %i[busy_percent core_clock fan_speed_rpm memory_clock power_draw temperature].each do |stat|
          task.async do
            send(stat).now = amdgpu_service.send(stat)
            calculate_stats(send(stat))
          end
        end
      end
    end

    private

    attr_reader :amdgpu_service

    def calculate_stats(stat_set)
      if num_measurements == 1
        stat_set.min = stat_set.now
        stat_set.avg = stat_set.now.to_f
        stat_set.max = stat_set.now
        return
      end

      stat_set.min = stat_set.now if stat_set.now < stat_set.min
      stat_set.avg =
        ((stat_set.now + (stat_set.avg * (num_measurements - 1))) / num_measurements.to_f)
        .round(1)
      stat_set.max = stat_set.now if stat_set.now > stat_set.max
    end
  end
end
