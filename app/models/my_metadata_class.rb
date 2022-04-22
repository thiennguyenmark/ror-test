class MyMetadataClass
  include ::MetadataAccessor

  attr_accessor :temp_data
  metadata_accessor :temp_data, as: :metadata
end
