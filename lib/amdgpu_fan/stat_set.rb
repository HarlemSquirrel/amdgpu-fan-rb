# frozen_string_literal: true

module AmdgpuFan
  # A set of stats
  class StatSet < Hash
    attr_accessor :avg, :max, :min, :now
    attr_reader :unit

    def initialize(unit)
      @unit = unit
    end

    def stats
      { min: min, avg: avg, max: max, now: now }
    end

    ##
    # Return a string containing all the stats with units.
    #
    def to_s
      stats.map { |k,v| "#{k}: #{v.to_s.rjust(6)} #{unit.ljust(3)} " }.join
    end
  end
end
