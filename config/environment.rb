# frozen_string_literal: true

require 'thor'

require_relative '../lib/amdgpu_fan'
require_relative '../lib/amdgpu_fan/version'

require_relative '../lib/amdgpu_fan/mixin/cli_output_format'
require_relative '../lib/amdgpu_fan/mixin/sys_write'

require_relative '../lib/amdgpu_fan/service'
require_relative '../lib/amdgpu_fan/cli'
require_relative '../lib/amdgpu_fan/pci'
require_relative '../lib/amdgpu_fan/stat_set'
require_relative '../lib/amdgpu_fan/watcher'
