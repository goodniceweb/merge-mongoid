class MyClass
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Document::Mergeable
  
  field :a_string, :type => String
  field :a_number, :type => Float
  field :a_boolean, :type => Boolean
  field :array_simple_types, :type => Array
  field :array_hashes, :type => Array
  field :a_hash, :type => Hash
  field :validate_string, :type => String

  validates :validate_string, presence: true, uniqueness: true

  has_many :childs # inverse_of: nil
  embeds_many :an_embeds, class_name: 'MyRandomClass'
end

class MyIngeritedClass < MyClass
  field :b_hash, :type => Hash
end
