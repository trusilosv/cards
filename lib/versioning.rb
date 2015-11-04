require 'yaml'
require 'versioning/has_versioning'

module Versioning
end

ActiveSupport.on_load(:active_record) do
  include Versioning::Model
end
