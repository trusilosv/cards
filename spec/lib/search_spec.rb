require 'helper'
require 'cards/models'

describe Cards::Search do
  let(:author_id) { 11111 }
  let(:another_author_id) { author_id + 1 }
  let(:project_id) { 22222 }
  let(:name) { "Name" }
  let(:description) { "Description" }
  let(:params) { { name: name, description: description, tag_list: "design", author_id: author_id, project_id: project_id } }
  let!(:first_card) { Cards.create_card(params) }
  let!(:second_card) { Cards.create_card(params.merge(name: 'Second', tag_list: ['bug', 'second'])) }

  describe '.by_keyword' do
    subject { described_class.by_keyword(project_id, keyword) }

    context 'when in name' do
      let(:keyword) { "Name" }

      it { expect(subject.first.id).to eq(first_card.id) }
      it { expect(subject.count).to eq(1) }
    end

    context 'when in description' do
      let(:keyword) { "Description" }

      it { expect(subject.first.id).to eq(second_card.id) }
      it { expect(subject.second.id).to eq(first_card.id) }
      it { expect(subject.count).to eq(2) }
    end

    context 'when in name of version' do
      let(:keyword) { "Name" }
      let(:new_name) { "New Title" }

      before(:each) do
        Cards.update_card(first_card.id, name: new_name, author_id: another_author_id)
      end

      it { expect(subject.first).to have_attributes(id: first_card.id, name: name, version: 1, current: false, author_id: author_id) }
      it { expect(subject.count).to eq(1) }

      context 'and in another version' do
        before(:each) do
          Cards.update_card(first_card.id, name: name, author_id: author_id)
        end

        it { expect(subject.first).to have_attributes(id: first_card.id, name: name, version: 3, current: true, author_id: author_id) }
        it { expect(subject.count).to eq(1) }
      end
    end

    context '[order]' do
      subject { described_class.by_keyword(project_id, keyword).map(&:id) }
      let(:keyword) { "Second" }

      let!(:third_card) { Cards.create_card params.merge(description: 'Second') }
      let!(:fourth_card) { Cards.create_card params.merge(name: 'Fourty Second') }
      let!(:fifth_card) { Cards.create_card params.merge(description: 'Fourty Second') }
      let!(:sixth_card) { Cards.create_card params.merge(name: 'Tags', tag_list: ['second']) }

      before(:each) do
        Cards.update_card(fifth_card.id, description: 'Fourty', author_id: another_author_id)
        Cards.update_card(second_card.id, name: 'Notcond', author_id: another_author_id)
      end

      it { is_expected.to eq([fourth_card.id, second_card.id, third_card.id, fifth_card.id, sixth_card.id]) }
    end
  end
end