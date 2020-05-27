# frozen_string_literal: true

module AmdgpuFan
  # Keep track of stats over time.
  class Watcher
    attr_reader :core_clock, :fan_speed, :num_measurements, :mem_clock, :power, :temp

    def initialize(amdgpu_service)
      @amdgpu_service = amdgpu_service
      @num_measurements = 0

      @core_clock = { min: nil, avg: nil, max: nil, now: nil }
      @mem_clock = { min: nil, avg: nil, max: nil, now: nil }
      @fan_speed = { min: nil, avg: nil, max: nil, now: nil }
      @power = { min: nil, avg: nil, max: nil, now: nil }
      @temp = { min: nil, avg: nil, max: nil, now: nil }
    end

    ##
    # Take a new set of measurements and adjust the stats.
    #
    def measure
      @num_measurements += 1

      @core_clock[:now] = @amdgpu_service.core_clock.to_i
      @mem_clock[:now] = @amdgpu_service.memory_clock.to_i
      @fan_speed[:now] = @amdgpu_service.fan_speed_rpm.to_i
      @power[:now] = @amdgpu_service.power_draw.to_f
      @temp[:now] = @amdgpu_service.temperature.to_i

      [@core_clock, @mem_clock, @fan_speed, @power, @temp].each do |stat_set|
        calculate_stats(stat_set)
      end
    end

    private

    def calculate_stats(stat_set)
      if num_measurements == 1
        stat_set[:min] = stat_set[:now]
        stat_set[:avg] = stat_set[:now].to_f
        stat_set[:max] = stat_set[:now]
        return
      end

      stat_set[:min] = stat_set[:now] if stat_set[:now] < stat_set[:min]
      stat_set[:avg] =
       ((stat_set[:now] + stat_set[:avg] * (num_measurements - 1)) / num_measurements.to_f)
         .round(1)
      stat_set[:max] = stat_set[:now] if stat_set[:now] > stat_set[:max]
    end
  end
end
