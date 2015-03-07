class Child
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Document::Mergeable

  field :a_string, :type => String
  field :a_number, :type => Float

  # without :class_name raise error "uninitialized constant MyClas"
  # .... o_0 WAT?
  belongs_to :my_class, class_name: 'MyClass' 
end
