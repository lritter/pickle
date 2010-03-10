module Pickle
  class ORM
    
    def self.model_classes
      raise NotImplementedError
    end
    
    def self.convert_nested_models_to_attributes(model_class, attrs)
      raise NotImplementedError
    end
    
    def self.first(model_class, conditions={})
      NotImplementedError
    end
    
    def self.all(model_class, conditions={})
      NotImplementedError
    end
    
    def self.find(model_class, id)
      NotImplementedError
    end
    
  end
  
  class ActiveRecordAdapter < ORM
    cattr_writer :model_classes
    self.model_classes = nil
    
    def self.model_classes
      @@model_classes ||= ::ActiveRecord::Base.send(:subclasses).reject do |klass|
        klass.abstract_class? || !klass.table_exists? ||
         (defined?(CGI::Session::ActiveRecordStore::Session) && klass == CGI::Session::ActiveRecordStore::Session) ||
         (defined?(::ActiveRecord::SessionStore::Session) && klass == ::ActiveRecord::SessionStore::Session)
      end
    end
    
    def self.convert_nested_models_to_attributes(ar_class, attrs)
      attrs.each do |key, val|
        if val.is_a?(ActiveRecord::Base) && ar_class.column_names.include?("#{key}_id")
          attrs["#{key}_id"] = val.id
          attrs["#{key}_type"] = val.class.name if ar_class.column_names.include?("#{key}_type")
          attrs.delete(key)
        end
      end
    end
    
    def self.first(model_class, conditions={})
      model_class.first(:conditions => convert_nested_models_to_attributes(model_class, conditions[:conditions]))
    end
    
    def self.all(model_class, conditions={})
      model_class.all(:conditions => convert_nested_models_to_attributes(model_class, conditions[:conditions]))
    end
    
    def self.find(model_class, id)
      model_class.find(id)
    end
    
  end
  
  class MongoMapperAdapter < ORM
    def self.model_classes
      []
    end
    
    def self.convert_nested_models_to_attributes(model_class, attrs)
      attrs.each do |key, val|
        if val.is_a?(MongoMapper::Document)
          attrs["#{key}_id"] = val.id
          attrs.delete(key)
        end
      end
    end
    
    def self.first(model_class, conditions={})
      model_class.first(:conditions => convert_nested_models_to_attributes(model_class, conditions[:conditions]))
    end
    
    def self.all(model_class, conditions={})
      model_class.all(:conditions => convert_nested_models_to_attributes(model_class, conditions[:conditions]))
    end
    
    def self.find(model_class, id)
      model_class.find(id)
    end
  end
  
end