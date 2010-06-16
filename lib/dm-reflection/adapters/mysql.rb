module DataMapper
  module Reflection
    module MysqlAdapter

      ##
      # Convert the database type into a DataMapper type
      #
      # @todo This should be verified to identify all mysql primitive types
      #       and that they map to the correct DataMapper/Ruby types.
      #
      # @param [String] db_type type specified by the database
      # @return [Type] a DataMapper or Ruby type object.
      #
      def get_type(db_type)
        # TODO: return a Hash with the :type, :min, :max and other
        # options rather than just the type

        db_type.match(/\A(\w+)/)
        {
          'tinyint'     =>  Integer    ,
          'smallint'    =>  Integer    ,
          'mediumint'   =>  Integer    ,
          'int'         =>  Integer    ,
          'bigint'      =>  Integer    ,
          'integer'     =>  Integer    ,
          'varchar'     =>  String     ,
          'char'        =>  String     ,
          'enum'        =>  String     ,
          'decimal'     =>  BigDecimal ,
          'double'      =>  Float      ,
          'float'       =>  Float      ,
          'datetime'    =>  DateTime   ,
          'timestamp'   =>  DateTime   ,
          'date'        =>  Date       ,
          'boolean'     =>  Types::Boolean,
          'tinyblob'    =>  Types::Text,
          'blob'        =>  Types::Text,
          'mediumblob'  =>  Types::Text,
          'longblob'    =>  Types::Text,
          'tinytext'    =>  Types::Text,
          'text'        =>  Types::Text,
          'mediumtext'  =>  Types::Text,
          'longtext'    =>  Types::Text,
        }[$1] || raise("unknown type: #{db_type}")
      end

      def separator
        '--'
      end

      ##
      # Get the list of table names
      #
      # @return [String Array] the names of the tables in the database.
      #
      def get_storage_names
        # This gets all the non view tables, but has to strip column 0 out of the two column response.
        select("SHOW FULL TABLES FROM #{options[:path][1..-1]} WHERE Table_type = 'BASE TABLE'").map { |item| item.first }
      end

      ##
      # This method breaks the join table into the two other table names
      #
      # @param [String] Name join table name
      # @return [String,String] The two other table names joined.
      # 
      def join_table_name(name, name_list=nil)
        name_list = get_storage_names.sort if name_list.nil?
        left = name_list[name_list.index(name)-1]
        right = name[left.length+1..-1]
        if name_list.include?(right)
          return left,right
        else
          return nil,nil
        end
      end

      ##
      # Get the column specifications for a specific table
      #
      # @todo Consider returning actual DataMapper::Properties from this.
      #       It would probably require passing in a Model Object.
      #
      # @param [String] table the name of the table to get column specifications for
      # @return [Hash] the column specs are returned in a hash keyed by `:name`, `:field`, `:type`, `:required`, `:default`, `:key`
      #
      def get_properties(table)
        # TODO: use SHOW INDEXES to find out unique and non-unique indexes
        join_table = false
        columns = select("SHOW COLUMNS FROM #{table} IN #{options[:path][1..-1]};")

        if columns.length == 2 && columns[0].field.downcase[-3,3] == "_id" && columns[1].field.downcase[-3,3] == "_id"
          left_table_name,right_table_name = join_table_name(table)
          join_table = true
        end
        
        columns.map do |column|
          type           = get_type(column.type)
          auto_increment = column.extra == 'auto_increment'

          if type == Integer && auto_increment
            type = DataMapper::Types::Serial
          end

          field_name = column.field.downcase

          attribute = {
            :name     => field_name,
            :type     => type,
            :required => column.null == 'NO',
            :default  => column.default,
            :key      => column.key == 'PRI',
          }
          
          # TODO: use the naming convention to compare the name vs the column name
          unless attribute[:name] == column.field
            attribute[:field] = column.field
          end
          
          if join_table
            attribute[:type] = :many_to_many
            attribute[:relationship] = {
              # M:M requires we wire things a bit differently and remove the join model
              :many_to_many => true,
              :parent => Extlib::Inflection.classify(left_table_name), 
              :child => Extlib::Inflection.classify(right_table_name), 
              # When we can detect more from the database we can optimize this
              :cardinality => Infinity, 
              :bidirectional => true }      
              return [attribute]      
          elsif type == Integer && field_name[-3,3] == "_id"
            # This is a foriegn key. So this model belongs_to the other (_id) one.
            # Add a special set of values and flag this as a relationship so the reflection code
            # can rebuild the relationship when it's building the model.
            attribute[:type] = :belongs_to
            
            attribute[:other_side] = { 
              :model => Extlib::Inflection.classify(field_name[0..-4]),
              :name => Extlib::Inflection.classify(field_name[0..-4]).pluralize,
              # When we can detect more from the database we can optimize this
              :cardinality => Infinity }
          end
          attribute
        end
      end
    end # module MysqlAdapter
  end # module Reflection
end # module DataMapper
