module Cards
  class Tag < ActiveRecord::Base
    include CardsBase

    attr_accessible :name, :project_id

    has_many :taggings

    before_save :check_for_name_coincidence

    validates :project_id, presence:  true
    validates :name, presence:  { message:  ": Tag can't be blank"},
              length:  { maximum:  255 }

    ### SCOPES:

    scope :not_deleted, -> { where(mark_as_deleted:  false) }

    def self.named(name)
      where(["name LIKE ? ESCAPE '!'", escape_like(name)])
    end

    def self.named_any(list)
      where(list.map { |tag| sanitize_sql(["name LIKE ? ESCAPE '!'", escape_like(tag.to_s)]) }.join(" OR "))
    end

    def self.named_like(name)
      where(["name LIKE ? ESCAPE '!'", "%#{escape_like(name)}%"])
    end

    def self.named_like_any(list)
      where(list.map { |tag| sanitize_sql(["name LIKE ? ESCAPE '!'", "%#{escape_like(tag.to_s)}%"]) }.join(" OR "))
    end

    ### CLASS METHODS:

    def self.find_or_create_all_with_like_by_name(project, *list)
      list = [list].flatten

      return [] if list.empty?

      existing_tags = project.tags.named_any(list).all
      new_tag_names = list.reject do |name|
        name = comparable_name(name)
        existing_tags.any? { |tag| comparable_name(tag.name) == name }
      end
      created_tags = new_tag_names.map { |name| project.tags.create(name:  name) }

      existing_tags + created_tags
    end

    ### INSTANCE METHODS:

    def ==(object)
      super || (object.is_a?(Tag) && name == object.name)
    end

    def to_s
      name
    end

    def count
      read_attribute(:count).to_i
    end

    class << self
      private
      def comparable_name(str)
        str.mb_chars.downcase.to_s
      end

      def escape_like(str)
        str.gsub(/[!%_]/) { |x| '!' + x }
      end
    end

    def destroy
      run_callbacks(:destroy) {
        self.update_column(:mark_as_deleted, !self.mark_as_deleted?)
      }
    end

    def check_for_name_coincidence
      if tag_with_same_name.any?
        self.taggings.each{ |tagging| tagging.update_attribute(:tag_id, tag_with_same_name.first.id) }
        tag_with_same_name.first.update_attribute(:mark_as_deleted, false)
        self.delete
      end
    end

    def tag_with_same_name
     Tag.where{(name == my{name}) & (id ^ my{id}) }.where(project_id: project_id)
    end
  end
end
