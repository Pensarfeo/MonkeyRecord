module ActiveRecord

  #Show attributes keys as symbols
  module AttributeMethods
    def attributes
      @attributes.to_hash.symbolize_keys
    end
  end

  module Core
    #avoid long output
    # Takes a PP and prettily prints this record to it, allowing you to get a nice result from `pp record`
    # when pp is required.
    def pretty_print(pp)
      pp.object_address_group(self) do
        if defined?(@attributes) && @attributes
          column_names = self.class.column_names.select { |name| has_attribute?(name) || new_record? }
          pp.text " "
          pp.seplist(column_names, proc { pp.text ', ' }) do |column_name|
            column_value = read_attribute(column_name)
            pp.group(1) do
            	pp.breakable ''
              pp.text "\e[33m"+column_name+": " +"\e[0m"
              pp.pp column_value
            end
          end
        else
          pp.breakable ' '
          pp.text 'not initialized'
        end
      end
    end

  end

end



