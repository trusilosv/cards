require 'spec_helper'

describe Cards::Tag do

  let(:project) { create :project }
  let(:story) { create :story, project:  project}
  let(:tag) { create :tag, project:  project, name:  'tag'}

  context 'tag renaming' do
    it 'should successfully rename tag' do
      tag.update_attribute(:name, 'new')
      tag.name.should == 'new'
    end

    it 'should delete self if tag with same name exists' do
      tag1 = create :tag, project:  project, name:  'tag1'
      tag.update_attribute(:name, 'tag1')
      project.tags.should == [tag1]
    end

    it 'should change update taggings with id of tag with same name' do
      tag1 = create :tag, project:  project, name:  'tag1'
      tagging = create :tagging, card: story.card, tag: tag
      tag.update_attribute(:name, 'tag1')
      tagging.tag.should == tag1
    end

    it 'should unmark as deleted tag with same name' do
      tag1 = create :tag, project:  project, name:  'tag1', mark_as_deleted:  true
      tag.update_attribute(:name, 'tag1')
      tag1.reload
      tag1.mark_as_deleted.should be false
    end
  end

  context 'tag deletion' do

    it "should not delete tag" do
      tag1 = create :tag, project:  project, name:  'tag1'
      tag2 = create :tag, project:  project, name:  'tag2'
      tag.destroy
      project.tags.should =~ [tag1, tag2, tag]
    end

    context 'with taggings' do
      before :each do
        tag.taggings.create story:  story
        tag.taggings.reload
      end

      it "should not destroy tag" do
        tag.destroy
        project.tags.should include tag
      end

      it "should mark as deleted" do
        tag.destroy
        tag.mark_as_deleted.should be true
      end

      it "should not delete mark as deleted tag" do
        tag.destroy
        tag.reload
        tag.should be_present
      end

      it "should not delete mark as deleted tag" do
        tag.update_attribute(:mark_as_deleted, true)
        tag1 = create :tag, project:  project, name:  'tag1'
        tag2 = create :tag, project:  project, name:  'tag2'
        tag.destroy
        project.tags.should =~ [tag, tag1, tag2]
      end
    end

  end

end
