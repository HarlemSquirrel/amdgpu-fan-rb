# frozen_string_literal: true

require_relative '../../../lib/amdgpu_fan/service'
require_relative '../../../lib/amdgpu_fan/watcher'
require 'spec_helper'

RSpec.describe AmdgpuFan::Watcher do
  let(:watcher) { described_class.new AmdgpuFan::Service.new }

  describe '#measure' do
    context 'when called the first time' do
      let(:blanks) { { avg: nil, max: nil, min: nil, now: nil } }
      let(:core_stats) { { avg: 852.0, max: 852, min: 852, now: 852 } }
      let(:fan_stats) { { avg: 1224.0, max: 1224, min: 1224, now: 1224 } }


      it { expect { watcher.measure }.to change(watcher, :core_clock).from(blanks).to(core_stats) }
      it { expect { watcher.measure }.to change(watcher, :fan_speed).from(blanks).to(fan_stats) }
    end
  end
end
