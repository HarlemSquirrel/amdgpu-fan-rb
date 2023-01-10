# frozen_string_literal: true

module AmdgpuFan
  # A mixin to help with writing to system files
  module SysWrite
    private

    ##
    # Write to a system file with elevated priviledges.
    def sudo_write(file_path, value)
      raise("wat")
      `echo "#{value}" | sudo tee #{file_path}`
    end
  end
end
