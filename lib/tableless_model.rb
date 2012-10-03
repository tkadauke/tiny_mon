# Port me to ActiveModel in Rails 3
class TablelessModel < ActiveRecord::Base
  self.abstract_class = true

  class_inheritable_array :columns
  self.columns = []
  
  def create_or_update # :nodoc:
    errors.empty?
  end

  # Prevent AR from associating to this record by ID; we should be serialized instead.
  private :quoted_id
  
  class << self
    def column(name, sql_type = nil, default = nil, null = true) # :nodoc:
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      reset_column_information
    end
    
    # Do not reset @columns
    def reset_column_information # :nodoc:
      generated_methods.each { |name| undef_method(name) }
      @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @generated_methods = nil
    end
  end
end