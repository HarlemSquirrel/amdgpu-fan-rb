# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/ClassLength, Metrics/MethodLength

require 'yaml'

module AmdgpuFan
  # The command-line interface class
  class Cli < Thor
    include CliOutputFormat

    ICONS = YAML.safe_load_file(File.join(__dir__, '../../config/icons.yml'))
                .transform_keys(&:to_sym).freeze
    WATCH_FIELD_SEPARATOR = ' | '

    def self.exit_on_failure?
      true
    end

    desc 'connectors', 'View the status of the display connectors.'
    def connectors
      amdgpu_service.connectors.each do |connector|
        puts "#{connector.type} #{connector.index}:\t" +
             (connector.connected? ? connector.display_name : connector.status)
      end
    end

    desc 'power_mode_auto', 'Set the power profile to automatic mode.'
    def power_mode_auto
      amdgpu_service.set_performance_level('auto')
      puts oneline_power_mode
    end

    desc 'power_mode_low',
         'Set the performance level to low to force the clocks to the lowest power state.'
    def power_mode_low
      amdgpu_service.set_performance_level('low')
      puts oneline_power_mode
    end

    desc 'power_mode_high',
         'Set the performance level to low to force the clocks to the highest power state.'
    def power_mode_high
      amdgpu_service.set_performance_level('high')
      puts oneline_power_mode
    end

    desc 'profile', 'View power profile details.'
    def profile
      puts amdgpu_service.profile_summary
    end

    desc 'profile_force PROFILE_NUM',
         'Set performance mode to manual and set a power profile. (requires sudo)'
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
      puts ICONS[:gpu] + ' GPU:'.ljust(11) + amdgpu_service.name
      puts ICONS[:vbios] + ' vBIOS:'.ljust(11) + amdgpu_service.vbios_version
      puts "#{ICONS[:display]} Displays: #{amdgpu_service.display_names.join(', ')}"
      puts ICONS[:clock] + ' Clocks:'.ljust(11) + clock_status
      puts ICONS[:memory] + ' Memory:'.ljust(11) + mem_total_mibibyes
      puts ICONS[:fan] + ' Fan:'.ljust(11) + fan_status
      puts ICONS[:temp] + ' Temp:'.ljust(11) + "#{amdgpu_service.temperature}°C"
      puts ICONS[:power] + ' Power:'.ljust(11) +
           "#{amdgpu_service.profile_mode} profile in " \
           "#{amdgpu_service.performance_level} mode using " \
           "#{amdgpu_service.power_draw} / #{amdgpu_service.power_max} Watts " \
           "(#{amdgpu_service.power_draw_percent}%)"
      puts ICONS[:load] + ' Load:'.ljust(11) + percent_meter(amdgpu_service.busy_percent, 12)
    end

    desc 'version', 'Print the application version.'
    def version
      puts AmdgpuFan::VERSION
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

    desc 'watch_avg',
         <<~DOC
           Watch min, max, average, and current stats.
         DOC
    def watch_avg
      puts "Watching #{amdgpu_service.name} min, max and averges since #{Time.now}...",
           '  <Press Ctrl-C to exit>',
           "\n\n\n\n\n"

      trap 'SIGINT' do
        puts "\nAnd now the watch is ended."
        exit 0
      end

      watcher = Watcher.new amdgpu_service

      loop do
        watcher.measure
        6.times { print "\033[K\033[A" } # move up a line and clear to end of line

        puts "#{ICONS[:load]} Load        #{watcher.busy_percent}",
             "#{ICONS[:clock]} Core clock  #{watcher.core_clock}",
             "#{ICONS[:memory]} Memory clk  #{watcher.memory_clock}",
             "#{ICONS[:fan]} Fan speed   #{watcher.fan_speed_rpm}",
             "#{ICONS[:power]} Power usage #{watcher.power_draw}",
             "#{ICONS[:temp]} Temperature #{watcher.temperature}"
        sleep 1
      end
    end

    desc 'watch_csv [SECONDS]', 'Watch stats in CSV format ' \
                                'refreshed every n seconds defaulting to 1 second.'
    def watch_csv(seconds = 1)
      return puts 'Seconds must be from 1 to 600' unless (1..600).cover?(seconds.to_i)

      puts 'Timestamp,Core Clock (Mhz),Memory Clock (Mhz),Fan speed (rpm),' \
           'Load (%),Power (Watts),Temp (°C)'

      trap 'SIGINT' do
        exit 0
      end

      loop do
        list = []
        threads = [
          Thread.new { list[0] = amdgpu_service.core_clock },
          Thread.new { list[1] = amdgpu_service.memory_clock },
          Thread.new { list[2] = amdgpu_service.fan_speed_rpm },
          Thread.new { list[3] = amdgpu_service.busy_percent },
          Thread.new { list[4] = amdgpu_service.power_draw },
          Thread.new { list[5] = amdgpu_service.temperature }
        ]
        threads.each(&:join)

        puts [Time.now.strftime('%F %T'), *list].join(',')

        sleep seconds.to_i
      end
    end

    private

    def amdgpu_service
      # Right now we're only looking at the first card.
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

    def power_max
      format('%<num>0.2f', num: amdgpu_service.power_max)
    end

    def oneline_power_mode
      "--> #{ICONS[:power]} #{amdgpu_service.performance_level} mode using " \
        "#{amdgpu_service.power_draw} / #{amdgpu_service.power_max} Watts " \
        "(#{amdgpu_service.power_draw_percent}%)"
    end

    def summary_clock
      "Core: #{amdgpu_service.core_clock.to_s.rjust(7)}#{WATCH_FIELD_SEPARATOR}" \
        "Memory: #{amdgpu_service.memory_clock.to_s.rjust(7)}"
    end

    def summary_fan
      fan_speed_string = "#{amdgpu_service.fan_speed_rpm} rpm".rjust(8)
      "Fan: #{fan_speed_string} #{percent_meter(amdgpu_service.fan_speed_percent)}"
    end

    def summary_load
      "Load: #{percent_meter amdgpu_service.busy_percent}"
    end

    def summary_power
      "Power: #{format('%<num>0.02f', num: amdgpu_service.power_draw).rjust(power_max.length)} W " \
        "#{percent_meter amdgpu_service.power_draw_percent}"
    end

    def summary_temp
      temp_string = "#{amdgpu_service.temperature}°C".rjust(7)
      "Temp: #{temp_string}"
    end
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/ClassLength, Metrics/MethodLength
