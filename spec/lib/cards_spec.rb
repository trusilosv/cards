require 'helper'

describe Cards do
  let(:author_id) { 11111 }
  let(:project_id) { 22222 }

  describe '.project_tags' do
    it 'returns empty' do
      expect(described_class.project_tags(1)).to be_empty
    end
  end

  describe '.find_card' do
    context 'when card does not exist' do
      it 'returns null' do
        expect(described_class.find_card(1)).to be_nil
      end
    end
  end

  describe '.create_card' do
    subject { described_class.create_card(params) }

    let(:params) { { name: "Name", description: "Description", tag_list: "design", author_id: author_id, project_id: project_id } }

    it { expect{subject}.to change { Cards::Card.count }.by(1) }
    it { expect{subject}.to change { Cards::Tag.count }.by(1) }
    it { expect{subject}.to change { Cards::CardVersion.count }.by(1) }
  end
end