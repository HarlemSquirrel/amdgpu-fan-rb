# frozen_string_literal: true

require_relative '../../../lib/amdgpu_fan/service'
require_relative '../../spec_helper'

RSpec.describe AmdgpuFan::Service do
  let(:base_dir) { File.expand_path('../../tmp', __dir__) }

  let(:amdgpu_service) { described_class.new }
  let(:file_dir) { "#{base_dir}/card0/device" }

  before do
    FileUtils.mkdir_p file_dir
    stub_const "#{described_class}::BASE_FOLDER", base_dir
  end

  describe '#busy_percent' do
    let(:percent) { rand(99) }
    let(:file_name) { 'gpu_busy_percent' }

    before do
      FileUtils.mkdir_p file_dir
      File.write("#{file_dir}/#{file_name}", percent)
    end

    it { expect(amdgpu_service.busy_percent).to eq percent.to_s }
  end

  describe '#fan_mode' do
    let(:file_name) { 'pwm1_enable' }
    let(:file_dir) { "#{base_dir}/card0/device/hwmon/hwmon0" }

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    context 'when 1' do
      let(:file_contents) { 1 }

      it { expect(amdgpu_service.fan_mode).to eq 'manual' }
    end

    context 'when 2' do
      let(:file_contents) { 2 }

      it { expect(amdgpu_service.fan_mode).to eq 'auto' }
    end
  end

  describe '#fan_speed_percent' do
    let(:file_dir) { "#{base_dir}/card0/device/hwmon/hwmon0" }
    let(:file_name) { 'pwm1' }
    let(:file_contents) { rand(255) }
    let(:percent) { (file_contents / 255.0 * 100).round }

    before do
      File.write("#{file_dir}/#{file_name}_max", "255\n")
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    it { expect(amdgpu_service.fan_speed_percent).to eq percent }
  end

  describe '#model_id' do
    let(:file_content) { '0xe37f' }
    let(:file_name) { 'subsystem_device' }

    before do
      FileUtils.mkdir_p file_dir
      File.write("#{file_dir}/#{file_name}", file_content)
    end

    it { expect(amdgpu_service.model_id).to eq 'E37F' }
  end

  describe '#name' do
    let(:name_string) { 'Advanced Micro Devices, Inc. [AMD/ATI] Radeon R9 FURY X / NANO' }

    before do
      File.write("#{file_dir}/device", '0x7300')
      File.write("#{file_dir}/subsystem_device", '0x0b36')
      File.write("#{file_dir}/vendor", '0x1002')
    end

    it { expect(amdgpu_service.name).to eq name_string }
  end

  describe '#power_dpm_state' do
    let(:file_name) { 'power_dpm_state' }

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    context 'when performance' do
      let(:file_contents) { 'performance' }

      it { expect(amdgpu_service.power_dpm_state).to eq file_contents }
    end
  end

  describe '#power_draw' do
    let(:file_name) { 'power1_average' }
    let(:file_contents) { 52_210_000 }
    let(:file_dir) { "#{base_dir}/card0/device/hwmon/hwmon0" }

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    it { expect(amdgpu_service.power_draw).to eq 52.21 }
  end

  describe '#power_draw_percent' do
    let(:file_dir) { "#{base_dir}/card0/device/hwmon/hwmon0" }
    let(:power_avg_file_name) { 'power1_average' }
    let(:power_avg_file_contents) { 52_210_000 }
    let(:power_cap_file_name) { 'power1_cap' }
    let(:power_cap_file_contents) { 300_000_000 }

    before do
      File.write("#{file_dir}/#{power_avg_file_name}", power_avg_file_contents)
      File.write("#{file_dir}/#{power_cap_file_name}", power_cap_file_contents)
    end

    it { expect(amdgpu_service.power_draw_percent).to eq 17 }
  end

  describe '#power_max' do
    let(:file_dir) { "#{base_dir}/card0/device/hwmon/hwmon0" }
    let(:file_name) { 'power1_cap' }
    let(:file_contents) { 300_000_000 }

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    it { expect(amdgpu_service.power_max).to eq 300.0 }
  end

  describe '#fan_mode=' do
    let(:file_dir) { "#{base_dir}/card0/device/hwmon/hwmon0" }
    let(:file_name) { 'pwm1_enable' }
    let(:file_path) { "#{file_dir}/#{file_name}" }

    before do
      FileUtils.mkdir_p file_dir
      FileUtils.touch(file_path)
      stub_sudo_write(file_path, expected_val)
    end

    context 'when manual is passed in' do
      let(:expected_val) { "1" }
      let(:mode) { 'manual' }

      it 'writes 1' do
        expect { amdgpu_service.fan_mode = mode }.to change { File.read(file_path) }.to "#{expected_val}\n"
      end
    end

    context 'when auto is passed in' do
      let(:expected_val) { "2" }
      let(:mode) { 'auto' }

      it 'writes 2' do
        expect { amdgpu_service.fan_mode = mode }.to change { File.read(file_path) }.to "#{expected_val}\n"
      end
    end
  end

  describe '#fan_speed=' do
    let(:error) { described_class::Error }
    let(:file_contents) { '' }
    let(:file_dir) { "#{base_dir}/card0/device/hwmon/hwmon0" }
    let(:file_name) { 'pwm1' }
    let(:enable_file_contents) { '2' }
    let(:enabled_file_name) { 'pwm1_enable' }
    let(:max_file_name) { 'pwm1_max' }
    let(:max_file_contents) { "255\n" }
    let(:min_file_name) { 'pwm1_max' }
    let(:min_file_contents) { "0\n" }

    before do
      File.write("#{file_dir}/#{min_file_name}", min_file_contents)
      File.write("#{file_dir}/#{max_file_name}", max_file_contents)
      File.write("#{file_dir}/#{enabled_file_name}", enable_file_contents)
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    context 'with no percent or raw provided' do
      it { expect { amdgpu_service.fan_speed = nil }.to raise_error error }
    end

    context 'when a valid percentage is given' do
      let(:value) { 25 }

      before do
        FileUtils.mkdir_p file_dir
        FileUtils.touch("#{file_dir}/#{file_name}")
        FileUtils.touch("#{file_dir}/#{enabled_file_name}")
        stub_sudo_write("#{file_dir}/#{file_name}", 64)
        stub_sudo_write("#{file_dir}/#{enabled_file_name}", '1')
      end

      it 'sets mode to manual by writing 1 to' do
        expect { amdgpu_service.fan_speed = value }
          .to change { File.read("#{file_dir}/#{enabled_file_name}") }
          .to "1\n"
      end

      it 'writes the proper raw fan speed' do
        expect { amdgpu_service.fan_speed = value }
          .to change { File.read("#{file_dir}/#{file_name}") }
          .to "64\n"
      end
    end
  end

  describe '#temperature' do
    let(:file_dir) { "#{base_dir}/card0/device/hwmon/hwmon0" }
    let(:file_name) { 'temp1_input' }
    let(:file_contents) { rand(29_000..79_999) }
    let(:temperature) { (file_contents / 1000.0).round(1) }

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    it { expect(amdgpu_service.temperature).to eq temperature }
  end

  describe '#vbios_version' do
    let(:file_name) { 'vbios_version' }
    let(:file_contents) { "vbios version string\n" }

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    it { expect(amdgpu_service.vbios_version).to eq 'vbios version string' }
  end
end

def stub_sudo_write(file_path, value)
  allow(amdgpu_service).to receive(:sudo_write)
    .with(file_path, value) { File.write file_path, "#{value}\n" }
end
