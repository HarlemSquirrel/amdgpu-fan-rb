# frozen_string_literal: true

require_relative '../config/environment'

# The main class
class AmdgpuFanCli < Thor
  METER_CHAR = '*'
  WATCH_FIELD_SEPARATOR = ' | '

  desc 'auto', 'Set fan mode to automatic (requires sudo)'
  def auto
    amdgpu_service.set_fan_mode! :auto
    puts fan_status
  end

  desc 'connectors', 'View the status of the display connectors'
  def connectors
    amdgpu_service.connectors_status.each do |connector,status|
      puts "#{connector}: #{status}"
    end
  end

  desc 'set PERCENTAGE', 'Set fan speed to PERCENTAGE (requires sudo)'
  def set(percentage)
    return puts "Invalid percentage" unless (0..100).cover?(percentage.to_i)

    amdgpu_service.set_fan_manual_speed! percent: percentage
    puts fan_status
  rescue AmdgpuService::Error
    puts 'Invalid fan speed provided. The percentage should be between 1 and 100'
    exit 1
  end

  desc 'status [--logo]', 'View device info, current fan speed, and temperature'
  def status(option = nil)
    puts radeon_logo if option == '--logo'
    puts "📺 #{'GPU:'.ljust(7)} #{amdgpu_service.name}",
         "📄 #{'vBIOS:'.ljust(7)} #{amdgpu_service.vbios_version}",
         "⏰ #{'Clocks:'.ljust(7)} #{clock_status}",
         "🌀 #{'Fan:'.ljust(7)} #{fan_status}",
         "🌞 #{'Temp:'.ljust(7)} #{amdgpu_service.temperature}°C",
         "⚡ #{'Power:'.ljust(7)} #{amdgpu_service.power_dpm_state} mode using " \
          "#{amdgpu_service.power_draw} / #{amdgpu_service.power_max} Watts "\
          "(#{amdgpu_service.power_draw_percent}%)",
         "⚖  #{'Load:'.ljust(7)} #{percent_meter amdgpu_service.busy_percent, 20}"
  end

  desc 'watch [SECONDS]', 'Watch fan speed, load, power, and temperature ' \
       'refreshed every n seconds'
  def watch(seconds=1)
    return puts "Seconds must be from 1 to 600" unless (1..600).cover?(seconds.to_i)

    puts "Watching #{amdgpu_service.name} every #{seconds} second(s)...",
         '  <Press Ctrl-C to exit>'

    trap "SIGINT" do
      puts "\nAnd now the watch is ended."
      exit 0
    end

    loop do
      puts [Time.now.strftime("%F %T"), summary_clock, summary_fan, summary_load, summary_power,
            summary_temp].join(WATCH_FIELD_SEPARATOR)

      sleep seconds.to_i
    end
  end

  desc 'watch_csv [SECONDS]', 'Watch stats in CSV format ' \
       'refreshed every n seconds defaulting to 1 second'
  def watch_csv(seconds=1)
    return puts "Seconds must be from 1 to 600" unless (1..600).cover?(seconds.to_i)

    puts 'Timestamp, Core Clock (Mhz),Memory Clock (Mhz),Fan speed (rpm), '\
         'Load (%),Power (Watts),Temp (°C)'

    trap "SIGINT" do
      exit 0
    end

    loop do
      puts [Time.now.strftime("%F %T"),
            amdgpu_service.core_clock,
            amdgpu_service.memory_clock,
            amdgpu_service.fan_speed_rpm,
            amdgpu_service.busy_percent,
            amdgpu_service.power_draw,
            amdgpu_service.temperature].join(',')
      sleep seconds.to_i
    end
  end

  private

  def amdgpu_service
    @amdgpu_service ||= AmdgpuService.new
  end

  def clock_status
    "#{amdgpu_service.core_clock} Core, #{amdgpu_service.memory_clock} Memory"
  end

  def current_time
    Time.now.strftime("%F %T")
  end

  def fan_status
    "#{amdgpu_service.fan_mode} mode running at " \
     "#{amdgpu_service.fan_speed_rpm} rpm (#{amdgpu_service.fan_speed_percent}%)"
  end

  def percent_meter(percent, length = 10)
    progress_bar_count = (length * percent.to_f / 100).round
    percent_string = "#{percent}%".ljust(4)
    "[#{METER_CHAR * progress_bar_count}#{' ' * (length - progress_bar_count)}]#{percent_string}"
  end

  def radeon_logo
    File.read(File.join(__dir__, '../lib/radeon_r_black_red_100x100.ascii'))
  end

  def summary_clock
    "Core: #{amdgpu_service.core_clock.ljust(7)} #{WATCH_FIELD_SEPARATOR}"\
      "Memory: #{amdgpu_service.memory_clock.ljust(7)}"
  end

  def summary_fan
    fan_speed_string = "#{amdgpu_service.fan_speed_rpm} rpm".ljust(8)
    "Fan: #{fan_speed_string} #{percent_meter(amdgpu_service.fan_speed_percent)}"
  end

  def summary_load
    "Load: #{percent_meter amdgpu_service.busy_percent}"
  end

  def summary_power
    power_string = "#{amdgpu_service.power_draw} W".ljust(amdgpu_service.power_max.to_s.length + 3)
    "Power: #{power_string} #{percent_meter amdgpu_service.power_draw_percent}"
  end

  def summary_temp
    temp_string = "#{amdgpu_service.temperature}°C".ljust(7)
    "Temp: #{temp_string}"
  end
end
