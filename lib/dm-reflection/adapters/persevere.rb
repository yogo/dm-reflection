module DataMapper
  module Reflection
    module PersevereAdapter
      extend Chainable

      ##
      # Convert the JSON Schema type into a DataMapper type
      #
      # @todo This should be verified to identify all mysql primitive types
      #       and that they map to the correct DataMapper/Ruby types.
      #
      # @param [String] db_type type specified by the database
      # @param [String] optional format format specification for string attributes
      # @return [Type] a DataMapper or Ruby type object.
      #
      chainable do
        def get_type(db_type)
          
          return :has_one_relation if db_type.has_key?("$ref") 
          
          type = db_type['type']
          format = db_type['format']

          case type
          when 'array'     then :has_many_relation
          when 'serial'    then DataMapper::Types::Serial
          when 'integer'   then Integer
          # when 'number'    then BigDecimal
          when 'number'    then Float
          when 'boolean'   then DataMapper::Types::Boolean
          when 'string'    then
            case format
              when nil         then DataMapper::Types::Text
              when 'date-time' then DateTime
              when 'date'      then Date
              when 'time'      then Time
            end
          end
        end
      end
      
      def separator
        '/'
      end
      
      ##
      # Get the list of schema names
      #
      # @return [String Array] the names of the schemas in the server.
      #
      def get_storage_names
        @schemas = self.get_schema
        @schemas.map { |schema| schema['id'] }
      end

      ##
      # Get the attribute specifications for a specific schema
      #
      # @todo Consider returning actual DataMapper::Properties from this.
      #       It would probably require passing in a Model Object.
      #
      # @param [String] table the name of the schema to get attribute specifications for
      # @return [Array] of hashes the column specs are returned in a hash keyed by `:name`, `:field`, `:type`, `:required`, `:default`, `:key`
      #
      chainable do
        def get_properties(table)
          attributes = Array.new
          schema = self.get_schema(table)[0]
          schema['properties'].each_pair do |key, value|
            type = get_type(value)
            
            attribute = { :name => key }
            
            if type == :has_one_relation
              # Has one
              # Retrieve the other side to determine the cardinality
              other_table = [table.split('/')[0..-2], value['$ref']].join("/")
              other_schema = self.get_schema(other_table)[0]

            elsif type == :has_many_relation
              # Has many
              # Retrieve the other side to determine the cardinality
              other_table = [table.split('/')[0..-2], value['items']['$ref']].join("/")
              other_schema = self.get_schema(other_table)[0]
              
            else
              attribute.merge!({ :type => type, :required => !value.delete('optional'), :key => value.has_key?('index') && value.delete('index') }) unless attribute[:type] == DataMapper::Types::Serial
              ['type', 'format', 'unique', 'index', 'items'].each { |key| value.delete(key) }
              value.keys.each { |key| value[key.to_sym] = value[key]; value.delete(key) }
              attribute.merge!(value)
              attributes << attribute
            end
          end
          return attributes
        end
      end

      private
      
      # Turns 'class_path/class' into 'ClassPath::Class
      def derive_relationship_model(input)
        input.match(/(Class)?\/([a-z\-\/\_]+)$/)[-1].split('/').map{|i| Extlib::Inflection.classify(i) }.join("::")
      end
      
    end # module PersevereAdapter
  end # module Reflection
end # module DataMapper
