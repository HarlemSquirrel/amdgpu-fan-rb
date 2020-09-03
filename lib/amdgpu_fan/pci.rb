# frozen_string_literal: true

require 'net/http'

module AmdgpuFan
  ## PCI
  #
  # Retrieve device information from PCI IDs.
  # https://pci-ids.ucw.cz/
  #
  class PCI
    TMP_FILE = '/tmp/pci.ids.txt'
    URL = 'https://pci-ids.ucw.cz/v2.2/pci.ids'

    ##
    # Return the device name if available
    #
    def self.device_name(vendor_id:, device_id:)
      info.dig vendor_id, :devices, device_id, :name
    end

    def self.info
      current_vendor_id = nil
      current_device_id = nil

      @info = raw.each_line.with_object({}) do |line, hash|
        next if line.empty? || line.start_with?('#')

        # Vendor line
        if line.start_with?(/(\d|[a-z])/)
          current_vendor_id = line.split('  ').first
          vendor_name = line.split('  ').last.strip
          hash[current_vendor_id] = { name: vendor_name, devices: {} }
        # Device line
        elsif line.start_with?(/\t\w/)
          current_device_id = line.split('  ').first.strip
          device_name = line.split('  ').last.strip
          hash[current_vendor_id][:devices][current_device_id] = { name: device_name }
        elsif line.start_with?(/\t\t\w/)
          subvendor_id = line.split(' ').first
          subdevice_id = line.split(' ')[1]
          subdevice_name = line.split('  ')[1]
          hash[current_vendor_id][:devices][current_device_id][subdevice_id] =
            { name: subdevice_name }
        end
      end
    end

    def self.raw
      File.write(TMP_FILE, Net::HTTP.get(URI(URL))) unless File.exist?(TMP_FILE)

      @raw ||= File.read(TMP_FILE)
    end
  end
end

