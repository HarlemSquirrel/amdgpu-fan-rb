# frozen_string_literal: true

require 'fileutils'

require_relative '../../lib/amdgpu_service'
require_relative '../spec_helper'

RSpec.describe AmdgpuService do
  BASE_DIR = File.expand_path('../../tmp', __dir__)

  let(:amdgpu_service) { described_class.new }
  let(:file_dir) { "#{BASE_DIR}/card0/device" }

  before do
    FileUtils.mkdir_p file_dir
    stub_const "#{described_class}::BASE_FOLDER", BASE_DIR
  end

  describe '#busy_percent' do
    let(:percent) { rand(99) }
    let(:file_name) { "gpu_busy_percent" }

    before do
      FileUtils.mkdir_p file_dir
      File.write("#{file_dir}/#{file_name}", percent)
    end

    it { expect(amdgpu_service.busy_percent).to eq percent.to_s }
  end

  describe '#fan_mode' do
    let(:file_name) { "pwm1_enable" }

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
    let(:file_name) { 'pwm1' }
    let(:file_contents) { rand(255) }
    let(:percent) { (file_contents / 255.0 * 100).round }

    before do
      File.write("#{file_dir}/#{file_name}_max", "255\n")
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    it { expect(amdgpu_service.fan_speed_percent).to eq percent }
  end

  describe '#name' do
    let(:name_string) { 'Advanced Micro Devices, Inc. [AMD/ATI] Radeon R9 FURY X / NANO' }

    before do
      allow(amdgpu_service).to receive(:lspci_subsystem).and_return("	Subsystem: #{name_string}")
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

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    it { expect(amdgpu_service.power_draw).to eq 52.21 }
  end

  describe '#power_draw_percent' do
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
    let(:file_name) { 'power1_cap' }
    let(:file_contents) { 300_000_000 }

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    it { expect(amdgpu_service.power_max).to eq 300.0 }
  end

  xdescribe '#set_mode!' do
    let(:file_name) { 'pwm1_enable' }
    let(:file_path) { "#{file_dir}/#{file_name}" }

    context 'when manual is passed in' do
      let(:mode) { 'manual' }

      it 'writes 1' do
        expect { amdgpu_service.set_mode!(mode) }.to change { File.read(file_path) }.to "1\n"
      end
    end

    context 'when auto is passed in' do
      let(:mode) { 'auto' }

      it 'writes 2' do
        expect { amdgpu_service.set_mode!(mode) }.to change { File.read(file_path) }.to "2\n"
      end
    end
  end

  describe '#set_fan_manual_speed!' do
    let(:error) { described_class::Error }
    let(:file_contents) { '255' }
    let(:file_name) { 'pwm1_max' }

    before do
      File.write("#{file_dir}/#{file_name}", file_contents)
    end

    context 'with no percent or raw provided' do
      it { expect { amdgpu_service.set_fan_manual_speed! }.to raise_error error }
    end
  end

  describe '#temperature' do
    let(:file_name) { 'temp1_input' }
    let(:file_contents) { rand(1000..9999) }
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
