# frozen_string_literal: true

module AmdgpuFan
  ## Connector
  #
  # A model class for a GPU connector
  class Connector
    EDID_DESCRIPTORS_CONF = {
      display_name_leading_bytes: String.new('\x00\xFC\x00', encoding: 'ascii-8bit'),
      unspecified_text_leading_bytes: String.new('\x00\xFE\x00', encoding: 'ascii-8bit'),
      index_range: (54..125)
    }.freeze

    attr_reader :card_num, :dir_path, :index, :type

    class << self
      ##
      # Return an array of connector objects for the provided card number.
      # The files are sorted to improve how they are displayed to the user.
      def where(card_num:)
        Dir["/sys/class/drm/card#{card_num}/card#{card_num}-*"].map do |dir_path|
          Connector.new card_num:,
                        dir_path:,
                        index: dir_path[-1],
                        type: dir_path.slice(/(?<=card#{card_num}-)[A-z]+/)
        end
      end
    end

    def initialize(card_num:, dir_path:, index:, type:)
      @card_num = card_num
      @dir_path = dir_path
      @index = index
      @type = type
    end

    def connected?
      status.casecmp('connected').zero?
    end

    def display_name
      return if edid.to_s.empty?

      (display_name_text + unspecified_text).join(' ').strip
    end

    def status
      File.read(File.join(dir_path, 'status')).strip
    end

    private

    def display_descriptors_raw
      edid.slice EDID_DESCRIPTORS_CONF[:index_range]
    end

    def display_name_text
      display_descriptors_raw
        .scan(/(?<=#{EDID_DESCRIPTORS_CONF[:display_name_leading_bytes]}).{1,13}/)
    end

    def edid
      File.read("#{dir_path}/edid", encoding: 'ascii-8bit')
    end

    def unspecified_text
      display_descriptors_raw
        .scan(/(?<=#{EDID_DESCRIPTORS_CONF[:unspecified_text_leading_bytes]}).{1,13}/)
    end
  end
end
