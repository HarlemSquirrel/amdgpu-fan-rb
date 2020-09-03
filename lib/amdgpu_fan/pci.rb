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
    def self.device_name(vendor_id, device_id, subdevice_id)
      device = info.dig vendor_id, :devices, device_id

      device.dig(subdevice_id, :name) || device[:name]
    end

    def self.vendor_name(vendor_id)
      info.dig vendor_id, :name
    end

    def self.info
      current_vendor_id = nil
      current_device_id = nil

      @info = raw.each_line.with_object({}) do |line, hash|
        next if line.empty? || line.start_with?('#')

        if line[0] =~ /(\d|[a-z])/
          # Vendor line
          current_vendor_id = line.split('  ').first.to_i(16)
          vendor_name = line.split('  ').last.strip
          hash[current_vendor_id] = { name: vendor_name, devices: {} }
        elsif line[0..1] =~ (/\t\w/)
          # Device line
          current_device_id = line.split('  ').first.to_i(16)
          device_name = line.split('  ').last.strip
          hash[current_vendor_id][:devices][current_device_id] = { name: device_name }
        elsif line.start_with?(/\t\t\w/)
          # Subvendor line
          subvendor_id = line.split(' ').first.to_i(16)
          subdevice_id = line.split(' ')[1].to_i(16)
          subdevice_name = line.split('  ')[1].strip
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
