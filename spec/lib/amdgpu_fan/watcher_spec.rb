# frozen_string_literal: true

require_relative '../../../lib/amdgpu_fan/service'
require_relative '../../../lib/amdgpu_fan/watcher'
require 'spec_helper'

RSpec.describe AmdgpuFan::Watcher do
  let(:base_dir) { File.expand_path('../../../tmp', __dir__) }
  let(:file_dir) { "#{base_dir}/card0/device" }
  let(:watcher) { described_class.new AmdgpuFan::Service.new }

  before do
    FileUtils.mkdir_p File.join(file_dir, 'hwmon/hwmon0')
    stub_const "#{AmdgpuFan::Service}::BASE_FOLDER", base_dir
    File.write File.join(file_dir, 'pp_dpm_sclk'), <<~DOC
      0: 852Mhz *
      1: 991Mhz
      2: 1084Mhz
      3: 1138Mhz
      4: 1200Mhz
      5: 1401Mhz
      6: 1536Mhz
      7: 1630Mhz
    DOC
    File.write File.join(file_dir, 'pp_dpm_mclk'), <<~DOC
      0: 167Mhz *
      1: 500Mhz
      2: 800Mhz
      3: 945Mhz
    DOC
    File.write File.join(file_dir, 'hwmon/hwmon0/fan1_input'), 1207
    File.write File.join(file_dir, 'hwmon/hwmon0/power1_average'), 8_000_000
    File.write File.join(file_dir, 'hwmon/hwmon0/temp1_input'), 25_000
  end

  describe '#measure' do
    context 'when called the first time' do
      let(:blanks) { { avg: nil, max: nil, min: nil, now: nil } }
      let(:core_stats) { 'min:    852 MHz avg:  852.0 MHz max:    852 MHz now:    852 MHz ' }
      let(:fan_stats) { 'min:   1207 RPM avg: 1207.0 RPM max:   1207 RPM now:   1207 RPM ' }

      it { expect { watcher.measure }.to change { watcher.core_clock.to_s }.to(core_stats) }
      it { expect { watcher.measure }.to change { watcher.fan_speed_rpm.to_s }.to(fan_stats) }
    end
  end
end
