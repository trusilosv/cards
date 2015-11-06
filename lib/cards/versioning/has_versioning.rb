module Cards
  module Versioning
    module Model

      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods
        def has_versioning(options = {})
          send :include, InstanceMethods

          class_attribute :only_versioning_column
          self.only_versioning_column = options[:only]

          const_set(:TIME_INTERVAL, options[:time_interval] || 1.hour)

          before_save :build_version

          class << self
            def has_versioning?
              true
            end
          end

          has_many :versions, class_name: "CardVersion"

        end

        def has_versioning?
          false
        end
      end

      module InstanceMethods
        def build_version
          if (changes.keys & only_versioning_column).any?
            if self.versions.any? && self.versions.last.author_id == self.author_id && self.versions.last.created_at + self.class::TIME_INTERVAL >= DateTime.current
              self.versions.last.update_attributes changes_values
            else
              self.version = version.to_i +  1
              self.versions.build changes_values.merge(author_id: self.author_id)
            end
          end
        end

        def changes_values
          changes = {}
          only_versioning_column.each { |key| changes.merge! key => self[key] }
          changes
        end
      end
    end
  end
end
