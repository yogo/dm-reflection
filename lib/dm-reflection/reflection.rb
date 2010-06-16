module DataMapper
  module Reflection
    ##
    # Main reflection method reflects models out of a repository.
    # @param [Slug] repository is the key to the repository that will be reflected.
    # @param [Constant] namespace is the namespace into which the reflected models will be added
    # @param [Boolean] overwrite indicates the reflected models should replace existing models or not.
    # @return [DataMapper::Model Array] the reflected models.
    #
    def self.reflect(repository, namespace = Object, overwrite = false)
      adapter = DataMapper.repository(repository).adapter
      separator = adapter.separator
      models  = Hash.new

      adapter.get_storage_names.each do |storage_name|
        namespace_parts = storage_name.split(separator).map do |part|
          Extlib::Inflection.classify(part)
        end

        model_name = namespace_parts.pop

        namespace = if namespace_parts.any?
          Object.make_module(namespace_parts.join('::'))
        else
          Object
        end

        next if namespace.const_defined?(model_name) && !overwrite

        anonymous_model = DataMapper::Model.new do
          class_eval <<-RUBY, __FILE__, __LINE__
            storage_names[#{repository.inspect}]='#{storage_name}'
          RUBY
          unless repository == DataMapper::Repository.default_name
            class_eval <<-RUBY, __FILE__, __LINE__
              def self.default_repository_name
                #{repository.inspect}
              end
            RUBY
          end
        end
        full_name = [namespace_parts, model_name].join('::')
        models[full_name] = namespace.const_set(model_name, anonymous_model)
      end

      join_models = Array.new
      
      models.each do |model_name, model|
        adapter.get_properties(model.storage_name).each do |attribute|
          if attribute[:type] == :many_to_many
            parent = models[attribute[:relationship][:parent].delete]
            child = models[attribute[:relationship][:child].delete]
            
            cardinality = attribute[:cardinality].delete
            parent.has(cardinality, child.name.split('::')[-1].tableize.pluralize.downcase.to_sym, attribute.merge({:through => DataMapper::Resource, :model => child}))
            child.has(cardinality, parent.name.split('::')[-1].tableize.pluralize.downcase.to_sym, attribute.merge({:through => DataMapper::Resource, :model => parent}))
            # Remove join model
            join_models << model_name
          elsif attribute[:type] == :has_n
            attribute.delete(:type)

            model.has(attribute.delete(:cardinality), attribute.delete(:name), attribute)
          elsif attribute[:type] == :belongs_to
            attribute.delete(:type)

            model.belongs_to(attribute.delete(:name), attribute)
            # if attribute[:relationship][:bidirectional]
            #   parent.has(attribute[:relationship][:cardinality], child.name.split('::')[-1].tableize.pluralize.downcase.to_sym, :model => child)
            # end
          else
            attribute.delete_if { |k,v| v.nil? }
            model.property(attribute.delete(:name).to_sym, attribute.delete(:type), attribute)
          end
        end
      end
          
      join_models.each do |model|
        models.delete(model)
        DataMapper::Model.descendants.delete(model)
      end

      models.values
    end
  end # module Reflection

  module Adapters
    extendable do
      ##
      # Glue method that will register reflection extensions for adapters if the adapters are loaded.
      #
      # @param [Constant] const_name is the constant defined by the adapter.
      # 
      # @api private
      def const_added(const_name)
        if DataMapper::Reflection.const_defined?(const_name)
          adapter = const_get(const_name)
          adapter.send(:include, DataMapper::Reflection.const_get(const_name))
        end
        super
      end # const_added
    end # extendable block
  end # module Adapters
end # module DataMapper
