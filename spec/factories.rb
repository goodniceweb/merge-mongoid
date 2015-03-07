FactoryGirl.define do 

  factory :child do
    _id { BSON::ObjectId.new.to_s }
    sequence(:a_string) { |n| "Another_String_#{n}" }
    sequence(:a_number) { |n| n }
  end
  
  factory :my_class do
    _id { BSON::ObjectId.new.to_s }
    sequence(:a_string) { |n| "A_String_#{n}" }
    sequence(:a_number) { |n| n}
    sequence(:a_boolean) { true}
    array_simple_types{["an","array","with","elements"]}
    array_hashes{[{
      "id" => BSON::ObjectId.new.to_s,
      "attribute" => "yes there is one"
    },{
      "id" => BSON::ObjectId.new.to_s,
      "attribute" => "a value here too"
    },{
      "id" => BSON::ObjectId.new.to_s,
      "other_attribute" => "hey"
    }]}
    a_hash{
      {
        "_id" => BSON::ObjectId.new.to_s,
        "a string" => "hello",
        "a number" => 12
      }
    }
    sequence(:validate_string) { |n| "Valid_String_#{n}" }
    childs { [FactoryGirl.create(:child), FactoryGirl.create(:child)] }
    an_embeds { [FactoryGirl.create(:child), FactoryGirl.create(:child)] }
  end
end
