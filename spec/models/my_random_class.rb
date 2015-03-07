class MyRandomClass
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Document::Mergeable
  
  field :a_string, :type => String
  field :a_number, :type => Float
  field :a_boolean, :type => Boolean
  field :array_simple_types, :type => Array
  field :array_hashes, :type => Array
  field :a_hash, :type => Hash
end
