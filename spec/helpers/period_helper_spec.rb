require 'rails_helper'

RSpec.describe PeriodHelper, type: :helper do
  describe '#period_breakdown' do
    it 'should return 1 day if given 86_400' do
      expect(period_breakdown(86_400)).to eq('1 day')
    end

    it 'should return 2 days if given 172_800' do
      expect(period_breakdown(172_800)).to eq('2 days')
    end

    it 'should return 1 week if given 604_800' do
      expect(period_breakdown(604_800)).to eq('1 week')
    end

    it 'should return 2 weeks, 1 day if given 1_296_000' do
      expect(period_breakdown(1_296_000)).to eq('2 weeks, 1 day')
    end

    it 'should return 1 month if given 2_628_000' do
      expect(period_breakdown(2_628_000)).to eq('1 month')
    end

    it 'should return 2 months, 2 days if given 5_428_800' do
      expect(period_breakdown(5_428_800)).to eq('2 months, 2 days')
    end

    it 'should return 1 year, 2 months, 1 week, 2 days if given 37_569_600' do
      expect(period_breakdown(37_569_600)).to eq('1 year, 2 months, 1 week, 2 days')
    end
  end
end
