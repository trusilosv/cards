require 'spec_helper'
describe Versioning::Model do

  it 'respond to the "has_versioning?" method' do
    ActiveRecord::Base.should respond_to(:has_versioning?)
    Story.should respond_to(:has_versioning?)
  end

  it 'return true for the "has_versioning?" method if the model is has_versioning' do
    Cards::Card.should be_has_versioning
  end

  it 'return false for the "has_versioning?" method if the model is not has_versioning' do
    ActiveRecord::Base.should_not be_has_versioning
  end

  describe "Story" do

    describe "Callbacks" do
      let!(:project) { create :project }
      let(:user) { create :user }
      let(:author) { create :user }
      let!(:story) { create :story, name: "Name", description: "Description", author: author}
      let(:tag) { create :tag }

      it 'should not create new record after saving object without changes' do
        expect {
          story.save
        }.to change { Cards::CardVersion.count }.by(0)
      end

      it 'should create one version after creating object' do
        expect {
          create :story, project: project
        }.to change { Cards::CardVersion.count }.by(1)
      end

      it 'should not create new version after update description object' do
        expect {
          story.update_attributes(description: "new description")
        }.to change { Cards::CardVersion.count }.by(0)
      end

      it 'should create one version after update description object' do
        story.update_attributes(description:  "new description")
        story.reload.versions.last.description.should == "new description"
        story.reload.versions.last.name.should == "Name"
      end

      it 'should not create new version if author and time is same' do
        new_story = create :story
        story.update_attributes(description:  "first description")
        expect {
          story.update_attributes(description:  "second description")
        }.to change { Cards::CardVersion.count }.by(0)
      end

      context 'should update previous version if author and time is same' do

        before {
          story.update_attributes(description: "first description")
          story.update_attributes(name: "third name")
        }

        subject { story.reload.versions.last }

        it { subject.description.should == "first description" }
        it { subject.name.should == "third name" }
        it { subject.version.should == 1 }
        it { story.version == 1 }
      end

      it 'should create new version if author is different' do
        story
        story.update_attributes(description:  "first description", author: author)

        expect {
          story.update_attributes(name:  "third name", author: user)
        }.to change { Cards::CardVersion.count }.by(1)
      end

      context 'should create new version if author is different' do

        before {
          story.update_attributes(description:  "first description", author: author)
          story.update_attributes(name:  "third name", author: user)
        }

        subject { story.reload.versions.last }

        it { subject.description.should == "first description" }
        it { subject.name.should == "third name" }
        it { subject.version.should == 2 }
        it { story.version == 2 }
      end

      it 'should create new version if time is different' do
        story
        story.update_attributes(description:  "first description")

        expect {
          Timecop.travel(DateTime.current + Cards::Card::TIME_INTERVAL + 1.minute) do
            story.update_attributes(name:  "third name")
          end
        }.to change { Cards::CardVersion.count }.by(1)
      end

      context 'should create new version if time is different' do
        before {
          story.update_attributes(description:  "first description")
           Timecop.travel(DateTime.current + Cards::Card::TIME_INTERVAL + 1.minute) do
            story.update_attributes(name:  "third name")
          end
        }

        subject { story.reload.versions.last }

        it { subject.description.should == "first description" }
        it { subject.name.should == "third name" }
        it { subject.version.should == 2 }
        it { story.version == 2 }
      end
    end
  end
end
