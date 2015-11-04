require 'helper'

describe Cards do
  describe '.project_tags' do
    it 'returns empty' do
      expect(Cards.project_tags(1)).to be_empty
    end
  end

  describe '.find_card' do
    context 'when card does not exist' do
      it 'returns null' do
        expect(Cards.find_card(1)).to be_nil
      end
    end
  end
end