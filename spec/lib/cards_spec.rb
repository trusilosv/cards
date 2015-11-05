require 'helper'

describe Cards do
  let(:author_id) { 11111 }
  let(:project_id) { 22222 }
  let(:name) { "Name" }
  let(:description) { "Description" }
  let(:params) { { name: name, description: description, tag_list: "design", author_id: author_id, project_id: project_id } }
  let!(:first_card) { described_class.create_card(params) }
  let!(:second_card) { described_class.create_card(params.merge(name: 'Second name', tag_list: 'bug')) }

  describe '.project_tags' do
    subject { described_class.project_tags(some_project_id) }
    let(:some_project_id) { project_id }

    context "when project doesn't exist" do
      let(:some_project_id) { 1 }

      it { is_expected.to be_empty }
    end

    context "when project has tags" do
      it { is_expected.to eq(%w[bug design]) }
    end
  end

  describe '.find_card' do
    subject { described_class.find_card(some_id) }

    context 'when card does not exist' do
      let(:some_id) { 99999 }

      it { is_expected.to be_nil }
    end

    context 'when cards are present' do
      let(:some_id) { first_card.id }

      it { expect(subject.name).to eq(name) }
      it { expect(subject.description).to eq(description) }
      it { expect(subject.id).to be_present }
      it { expect(subject.tag_names).to eq(['design']) }
    end
  end

  describe '.create_card' do
    subject { described_class.create_card(params.merge(tag_list: "new_tag")) }

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