require 'helper'
require 'cards/models'

describe Cards::Search do
  let(:author_id) { 11111 }
  let(:project_id) { 22222 }
  let(:name) { "Name" }
  let(:description) { "Description" }
  let(:params) { { name: name, description: description, tag_list: "design", author_id: author_id, project_id: project_id } }
  let!(:first_card) { Cards.create_card(params) }
  let!(:second_card) { Cards.create_card(params.merge(name: 'Second', tag_list: 'bug')) }
  
  describe '.by_keyword' do
    subject { described_class.by_keyword(project_id, keyword) }
    
    context 'when in name' do
      let(:keyword) { "Name" }
      
      it { expect(subject.first.id).to eq(first_card.id) }
    end
  end
end