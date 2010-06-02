require File.dirname(__FILE__) + '/spec_helper'

if ENV['ADAPTER'] == 'persevere'
  
  POST = <<-RUBY
  class Post

    include DataMapper::Resource

    property :id, Serial

    property :created_at, DateTime
    property :body, Text, :length => 65535, :lazy => true
    property :updated_at, DateTime


  end
  RUBY

  POST_COMMENT = <<-RUBY
  class PostComment

    include DataMapper::Resource

    property :id, Serial

    property :created_at, DateTime
    property :body, Text, :length => 65535, :lazy => true
    property :updated_at, DateTime
    property :score, Integer

  end
  RUBY
  
  PERSEVERE_REFLECTION_SOURCES = [ POST, POST_COMMENT ]
  
  describe 'The Persevere DataMapper reflection module' do
  
    before(:each) do
      @adapter = repository(:default).adapter
      
       PERSEVERE_REFLECTION_SOURCES.each { |source| eval(source) }

        @models = {
          :Post            => POST,
          :PostComment     => POST_COMMENT,
        }

        @models.each_key { |model| Extlib::Inflection.constantize(model.to_s).auto_migrate! }
        @models.each_key { |model| remove_model_from_memory( Extlib::Inflection.constantize(model.to_s) ) }
    end
    
    after(:each) do
      @models.each_key do |model_name|
        next unless Object.const_defined?(model_name)
        model = Extlib::Inflection.constantize(model_name.to_s)
        remove_model_from_memory(model)
      end
      @models.each_key do |model_name|
        next unless Object.const_defined?(model_name)
        model = Extlib::Inflection.constantize(model_name.to_s)
        remove_model_from_memory(model)
      end
    end
  
    it "should return an array of tables" do
      @adapter.get_storage_names.should be_kind_of(Array)
    end
  
    it "should return a table definition" do
      result = @adapter.get_properties("post")
      result.should be_kind_of(Array)
    end

  end
end