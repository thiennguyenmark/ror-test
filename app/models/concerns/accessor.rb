frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"


module MetadataAccessor
 extend ActiveSupport::Concern

 included do
   class << self
     attr_accessor :local_stored_attributes
   end
 end

 module ClassMethods
   def store(store_attribute, options = {})
     serialize store_attribute, IndifferentCoder.new(store_attribute, options[:coder])
     attr_accessor(store_attribute, options[:accessors], **options.slice(:prefix, :suffix)) if options.has_key? :accessors
   end

   def attr_accessor(store_attribute, *keys, prefix: nil, suffix: nil)
     keys = keys.flatten

     accessor_prefix =
       case prefix
       when String, Symbol
         "#{prefix}_"
       when TrueClass
         "#{store_attribute}_"
       else
         ""
       end
     accessor_suffix =
       case suffix
       when String, Symbol
         "_#{suffix}"
       when TrueClass
         "_#{store_attribute}"
       else
         ""
       end

     _store_accessors_module.module_eval do
       keys.each do |key|
         accessor_key = "#{accessor_prefix}#{key}#{accessor_suffix}"

         define_method("#{accessor_key}=") do |value|
           write_store_attribute(store_attribute, key, value)
         end

         define_method(accessor_key) do
           read_store_attribute(store_attribute, key)
         end
       end
     end

     # assign new store attribute and create new hash to ensure that each class in the hierarchy
     # has its own hash of stored attributes.
     self.local_stored_attributes ||= {}
     self.local_stored_attributes[store_attribute] ||= []
     self.local_stored_attributes[store_attribute] |= keys
   end

   def _store_accessors_module # :nodoc:
     @_store_accessors_module ||= begin
       mod = Module.new
       include mod
       mod
     end
   end

   def stored_attributes
     parent = superclass.respond_to?(:stored_attributes) ? superclass.stored_attributes : {}
     if local_stored_attributes
       parent.merge!(local_stored_attributes) { |k, a, b| a | b }
     end
     parent
   end
 end

 private
   def read_store_attribute(store_attribute, key) # :doc:
     accessor = store_accessor_for(store_attribute)
     accessor.read(self, store_attribute, key)
   end

   def write_store_attribute(store_attribute, key, value) # :doc:
     accessor = store_accessor_for(store_attribute)
     accessor.write(self, store_attribute, key, value)
   end

   def store_accessor_for(store_attribute)
     type_for_attribute(store_attribute).accessor
   end

   class HashAccessor # :nodoc:
     def self.read(object, attribute, key)
       prepare(object, attribute)
       object.public_send(attribute)[key]
     end

     def self.write(object, attribute, key, value)
       prepare(object, attribute)
       if value != read(object, attribute, key)
         object.public_send :"#{attribute}_will_change!"
         object.public_send(attribute)[key] = value
       end
     end

     def self.prepare(object, attribute)
       object.public_send :"#{attribute}=", {} unless object.send(attribute)
     end
   end

   class StringKeyedHashAccessor < HashAccessor # :nodoc:
     def self.read(object, attribute, key)
       super object, attribute, key.to_s
     end

     def self.write(object, attribute, key, value)
       super object, attribute, key.to_s, value
     end
   end

   class IndifferentHashAccessor < ActiveRecord::MetadataAccessor::HashAccessor # :nodoc:
     def self.prepare(object, store_attribute)
       attribute = object.send(store_attribute)
       unless attribute.is_a?(ActiveSupport::HashWithIndifferentAccess)
         attribute = IndifferentCoder.as_indifferent_hash(attribute)
         object.public_send :"#{store_attribute}=", attribute
       end
       attribute
     end
   end

   class IndifferentCoder # :nodoc:
     def initialize(attr_name, coder_or_class_name)
       @coder =
         if coder_or_class_name.respond_to?(:load) && coder_or_class_name.respond_to?(:dump)
           coder_or_class_name
         else
           ActiveRecord::Coders::YAMLColumn.new(attr_name, coder_or_class_name || Object)
         end
     end

     def self.as_indifferent_hash(obj)
       case obj
       when ActiveSupport::HashWithIndifferentAccess
         obj
       when Hash
         obj.with_indifferent_access
       else
         ActiveSupport::HashWithIndifferentAccess.new
       end
     end
   end
end
