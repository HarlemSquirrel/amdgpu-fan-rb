# frozen_string_literal: true

require_relative '../config/environment'

# The main class
class AmdgpuFanCli < Thor
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

  desc 'status', 'View device info, current fan speed, and temperature'
  def status
    puts radeon_logo,
         "📺\tGPU:   #{amdgpu_service.name}",
         "📄\tvBIOS: #{amdgpu_service.vbios_version}",
         clock_status,
         fan_status,
         "🌡\tTemp:  #{amdgpu_service.temperature}°C",
         "⚡\tPower: #{amdgpu_service.power_dpm_state} mode using " \
          "#{amdgpu_service.power_draw} / #{amdgpu_service.power_max} Watts "\
          "(#{amdgpu_service.power_draw_percent}%)",
         "⚖\tLoad: #{percent_meter amdgpu_service.busy_percent, 20}"
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
      puts "#{Time.now.strftime("%F %T")} - " \
           "Clock: #{amdgpu_service.core_clock} Core, #{amdgpu_service.memory_clock} Memory,\t" \
           "Fan: #{amdgpu_service.fan_speed_rpm} rpm #{percent_meter amdgpu_service.fan_speed_percent},\t" \
           "Load: #{percent_meter amdgpu_service.busy_percent},\t" \
           "Power: #{amdgpu_service.power_draw} W #{percent_meter amdgpu_service.power_draw_percent},\t" \
           "Temp: #{amdgpu_service.temperature}°C "
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
    "⏰\tClocks: #{amdgpu_service.core_clock} Core, " \
    "#{amdgpu_service.memory_clock} Memory"
  end

  def current_time
    Time.now.strftime("%F %T")
  end

  def fan_status
    "🌀\tFan:   #{amdgpu_service.fan_mode} mode running at " \
     "#{amdgpu_service.fan_speed_rpm} rpm (#{amdgpu_service.fan_speed_percent}%)"
  end

  def percent_meter(percent, length = 10)
    progress_bar_count = (length * percent.to_f / 100).round
    "[#{'|' * progress_bar_count}#{' ' * (length - progress_bar_count)}]#{percent}%"
  end

  def radeon_logo
    File.read(File.join(__dir__, '../lib/radeon_r_black_red_100x100.ascii'))
  end
end
