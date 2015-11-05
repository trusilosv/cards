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

    let(:name) { "Name" }
    let(:description) { "Description" }
    let(:params) { { name: name, description: description, tag_list: "design", author_id: author_id, project_id: project_id } }

    it { expect{subject}.to change { Cards::Card.count }.by(1) }
    it { expect{subject}.to change { Cards::Tag.count }.by(1) }
    it { expect{subject}.to change { Cards::CardVersion.count }.by(1) }

    context 'response' do
      it { expect(subject.name).to eq(name) }
      it { expect(subject.description).to eq(description) }
      it { expect(subject.id).to be_present }
    end

    context 'created objects' do
      subject! { described_class.create_card(params) }

      context 'card' do
        def card
          Cards::Card.first
        end

        it { expect(card.name).to eq(name) }
        it { expect(card.description).to eq(description) }
      end
    end
  end
end