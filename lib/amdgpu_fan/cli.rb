# frozen_string_literal: true

module AmdgpuFan
  # The command-line interface class
  class Cli < Thor
    include CliOutputFormat

    WATCH_FIELD_SEPARATOR = ' | '

    desc 'connectors', 'View the status of the display connectors.'
    def connectors
      amdgpu_service.connectors.each do |connector|
        puts "#{connector.type} #{connector.index}:\t#{connector.status}" \
             "    #{connector.display_name}".chomp
      end
    end

    desc 'profile', 'View power profile details.'
    def profile
      puts amdgpu_service.profile_summary
    end

    desc 'profile_auto', 'Set the power profile to automatic mode.'
    def profile_auto
      amdgpu_service.profile_auto
      puts amdgpu_service.profile_summary
    end

    desc 'profile_force PROFILE_NUM', 'Manually set a power profile. (requires sudo)'
    def profile_force(state)
      amdgpu_service.profile_force = state
      puts amdgpu_service.profile_summary
    end

    desc 'fan', 'View fan details.'
    def fan
      puts fan_status
    end

    desc 'fan_set PERCENTAGE/AUTO', 'Set fan speed to percentage or automatic mode. (requires sudo)'
    def fan_set(value)
      if value.strip.casecmp('auto').zero?
        amdgpu_service.fan_mode = :auto
      else
        return puts 'Invalid percentage' unless (0..100).cover?(value.to_i)

        amdgpu_service.fan_speed = value
      end
      puts fan_status
    end

    desc 'status [--logo]', 'View device info, current fan speed, and temperature.'
    def status(option = nil)
      puts radeon_logo if option == '--logo'
      puts "Displays: #{amdgpu_service.connectors.map(&:display_name).compact.join(',')}",
           "📺 #{'GPU:'.ljust(7)} #{amdgpu_service.name}",
           "📄 #{'vBIOS:'.ljust(7)} #{amdgpu_service.vbios_version}",
           "⏰ #{'Clocks:'.ljust(7)} #{clock_status}",
           "💾 #{'Memory:'.ljust(7)} #{mem_total_mibibyes}",
           "🌀 #{'Fan:'.ljust(7)} #{fan_status}",
           "🌞 #{'Temp:'.ljust(7)} #{amdgpu_service.temperature}°C",
           "⚡ #{'Power:'.ljust(7)} #{amdgpu_service.profile_mode} profile in " \
            "#{amdgpu_service.power_dpm_state} mode using " \
            "#{amdgpu_service.power_draw} / #{amdgpu_service.power_max} Watts "\
            "(#{amdgpu_service.power_draw_percent}%)",
           "⚖  #{'Load:'.ljust(7)} #{percent_meter amdgpu_service.busy_percent, 20}"
    end

    desc 'watch [SECONDS]', 'Watch fan speed, load, power, and temperature ' \
         'refreshed every n seconds.'
    def watch(seconds = 1)
      return puts 'Seconds must be from 1 to 600' unless (1..600).cover?(seconds.to_i)

      puts "Watching #{amdgpu_service.name} every #{seconds} second(s)...",
           '  <Press Ctrl-C to exit>'

      trap 'SIGINT' do
        puts "\nAnd now the watch is ended."
        exit 0
      end

      loop do
        time = Time.now
        puts [time.strftime('%F %T'), summary_clock, summary_fan, summary_load, summary_power,
              summary_temp].join(WATCH_FIELD_SEPARATOR)

        # It can take a second or two to run the above so we remove them from the wait
        # here to get a more consistant watch interval.
        sec_left_to_wait = time.to_i + seconds.to_i - Time.now.to_i
        sleep sec_left_to_wait if sec_left_to_wait.positive?
      end
    end

    desc 'watch_csv [SECONDS]', 'Watch stats in CSV format ' \
         'refreshed every n seconds defaulting to 1 second.'
    def watch_csv(seconds = 1)
      return puts 'Seconds must be from 1 to 600' unless (1..600).cover?(seconds.to_i)

      puts 'Timestamp, Core Clock (Mhz),Memory Clock (Mhz),Fan speed (rpm), '\
           'Load (%),Power (Watts),Temp (°C)'

      trap 'SIGINT' do
        exit 0
      end

      loop do
        puts [Time.now.strftime('%F %T'),
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
      @amdgpu_service ||= AmdgpuFan::Service.new
    end

    def clock_status
      "#{amdgpu_service.core_clock} Core, #{amdgpu_service.memory_clock} Memory"
    end

    def fan_status
      "#{amdgpu_service.fan_mode} mode running at " \
       "#{amdgpu_service.fan_speed_rpm} rpm (#{amdgpu_service.fan_speed_percent}%)"
    end

    def mem_total_mibibyes
      "#{amdgpu_service.memory_total / (2**20)} MiB"
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
      "Power: #{amdgpu_service.power_draw.to_s.rjust(amdgpu_service.power_max.to_s.length + 1)} W" \
        "#{percent_meter amdgpu_service.power_draw_percent}"
    end

    def summary_temp
      temp_string = "#{amdgpu_service.temperature}°C".ljust(7)
      "Temp: #{temp_string}"
    end
  end
end
