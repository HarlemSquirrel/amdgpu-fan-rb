# frozen_string_literal: true

module AmdgpuFan
  ## Connector
  #
  # A model class for a GPU connector
  class Connector
    attr_reader :card_num, :dir_path, :index, :type

    class << self
      ##
      # Return an array of connector objects for the provided card number.
      # The files are sorted to improve how they are displayed to the user.
      def where(card_num:)
        Dir["/sys/class/drm/card#{card_num}/card#{card_num}-*"].sort.map do |dir_path|
          Connector.new card_num: card_num,
                        dir_path: dir_path,
                        index: dir_path[-1],
                        type: dir_path.slice(/(?<=card#{card_num}-)[A-Z]+/)
        end
      end
    end

    def initialize(card_num:, dir_path:, index:, type:)
      @card_num = card_num
      @dir_path = dir_path
      @index = index
      @type = type
    end

    def status
      File.read(File.join(dir_path, 'status')).strip
    end
  end
end
