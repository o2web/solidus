require 'spec_helper'

describe Spree::Country, type: :model do
  describe '.default' do
    before do
      create(:country, iso: "DE", id: 1)
      create(:country, id: 2)
    end

    subject(:default_country) { described_class.default }

    context 'with the configuration setting an existing legacy default country ID' do
      before do
        Spree::Config[:default_country_id] = 2
      end

      it 'emits a deprecation warning' do
        expect(ActiveSupport::Deprecation).to receive(:warn)
        default_country
      end

      it 'is the country with that ID' do
        expect(default_country).to eq(Spree::Country.find(2))
      end
    end

    context 'with the configuration setting a non-existing legacy default country ID' do
      before do
        Spree::Config[:default_country_id] = 0
      end

      it 'loads the country configured by the ISO code' do
        expect(default_country).to eq(Spree::Country.find(2))
      end
    end

    context 'with the configuration setting an existing ISO code' do
      it 'is a country with the configurations ISO code' do
        expect(described_class.default).to be_a(Spree::Country)
        expect(described_class.default.iso).to eq('US')
      end
    end

    context 'with the configuration setting an non-existing ISO code' do
      before { Spree::Config[:default_country_iso] = "ZZ" }

      it 'raises a Record not Found error' do
        expect { described_class.default }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
