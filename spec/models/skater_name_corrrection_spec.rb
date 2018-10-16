require 'rails_helper'

RSpec.describe SkaterNameCorrection do
  describe 'correction' do
    it {
      name = 'Sandra KOHPON'
      expect(SkaterNameCorrection.correct(name)).to eq('Sandra KHOPON')
    }
  end
  describe 'normalize' do
    it {
      name = 'FOO Bar'
      expect(SkaterNameCorrection.correct(name)).to eq('Bar FOO')
    }
  end
end
