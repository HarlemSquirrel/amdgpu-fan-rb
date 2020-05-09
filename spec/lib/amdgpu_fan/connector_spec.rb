# frozen_string_literal: true

require_relative '../../../lib/amdgpu_fan/connector'
require 'spec_helper'

RSpec.describe AmdgpuFan::Connector do
  let(:connector) { described_class.new card_num: 0, dir_path: dir_path, index: 1, type: type }
  
  describe '#display_name' do
    context 'with a AUO B173HAN03.2 display on DP 1' do
      let(:dir_path) { File.expand_path '../../fixtures/AUO_B173HAN03.2/card0-eDP-1', __dir__ }
      let(:type) { 'DP' }

      it { expect(connector.display_name).to eq 'AUO B173HAN03.2' }
    end

    context 'with a GeChic OnLap 1503 display on HDMI-A 1' do
      let(:dir_path) do
        File.expand_path '../../fixtures/GeChic_OnLap_1503/card0-HDMI-A-1', __dir__
      end
      let(:type) { 'DP' }

      it { expect(connector.display_name).to eq 'Onlap1503' }
    end

    context 'with a Pixio PX277 display on DP 1' do
      let(:dir_path) { File.expand_path '../../fixtures/Pixio_px277/card0-DP-1', __dir__ }
      let(:type) { 'DP' }

      it { expect(connector.display_name).to eq 'DP_FREESYNC' }
    end
  end

end
 
