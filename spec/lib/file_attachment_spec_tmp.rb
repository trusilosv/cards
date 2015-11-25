require 'spec_helper'

shared_examples_for "Polymorphic Attachment" do

  describe "create" do
    def do_create
      @attachable.attachments.create!
      @attachable.reload
    end

    it "should update attachable.attachments_cache" do
      do_create
      @attachable.attachments_cache.should == "#{@attachable.attachments[0].id},#{@attachable.attachments[1].id}"
    end

    it "should add attachment to attachable.current_attachments" do
      lambda {
        do_create
      }.should change { @attachable.current_attachments.size }.by(1)
    end

    it "should add attachment to attachable.attachments" do
      lambda {
        do_create
      }.should change { @attachable.attachments.size }.by(1)
    end
  end

  describe "destroy" do
    def do_delete
      @attachment.destroy
      @attachable.reload
    end

    it "should update attachable.attachments_cache" do
      do_delete
      @attachable.attachments_cache.should == ""
    end

    it "should delete attachment from attachable.current_attachments" do
      lambda {
        do_delete
      }.should change { @attachable.current_attachments.size }.by(-1)
    end

    it "shouldn't delete attachment from attachable.attachments" do
      lambda {
        do_delete
      }.should_not change { @attachable.attachments.size }
    end

  end
end

describe Cards::FileAttachment do
  before :each do
    @project = create :project
    @developer = create :developer_user, project: @project
    @task = TaskTimeBuilder.new.for_user(@developer).and.for_project(@project).today.build.to_hash[:task]
    @story = @task.story
  end

  describe "when attached to story" do
    before(:each) do
      @attachable = @story
      @attachment = FileAttachmentBuilder.new.for_parent(@attachable).for_author(@developer).build.file_attachment
    end

    it_should_behave_like "Polymorphic Attachment"
  end

  describe "when attached to task" do
    before(:each) do
      @attachable = @task
      @attachment = FileAttachmentBuilder.new.for_parent(@attachable).for_author(@developer).build.file_attachment
    end

    it_should_behave_like "Polymorphic Attachment"
  end

  describe "when attached to project" do
    before(:each) do
      @attachable = @project
      @attachment = FileAttachmentBuilder.new.for_parent(@attachable).for_author(@developer).build.file_attachment
    end

    it_should_behave_like "Polymorphic Attachment"
  end

  describe "#attached?" do
    let (:project) { create :project }
    before do
      @attachment = project.attachments.create!
    end

    it "should return true if file attached to object" do
      @attachment.attached?.should == true
    end

    it "should return false if file not attached" do
      @attachment.attachable.stubs(:attachments_cache).returns([])
      @attachment.attached?.should == false
    end
  end

  describe "#extension" do
    before(:each) do
      @file = described_class.new
    end

    it "should return extension of file with one dot in filename" do
      @file.file_file_name = "doc_file.doc"
      @file.extension.should == "doc"
    end

    it "should return extension of file with some dots in filename" do
      @file.file_file_name = "doc_file.doc.sss"
      @file.extension.should == "sss"
    end

    it "should return empty string for file without extension" do
      @file.file_file_name = "doc_file"
      @file.extension.should == ""
    end
  end
end
