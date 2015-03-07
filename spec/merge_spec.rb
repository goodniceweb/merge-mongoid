require "spec_helper"

describe Mongoid::Document::Mergeable do
  describe ".merge" do
    let(:master) { FactoryGirl.build(:my_class) }
    let(:slave)  { FactoryGirl.build(:my_class) }
    let(:master_copy) { master }
    let(:master_with_assocs) { FactoryGirl.build(:my_class_with_associations) }
    let(:slave_with_assocs)  { FactoryGirl.build(:my_class_with_associations) }
    let(:run_regular_merge_method) { master.merge! slave }

    it "should create objects with a 'merge!' method" do
      expect(master.methods).to include(:merge!)
    end

    context "when use :merge! method" do
      before do
        run_regular_merge_method
      end
    
      it "keep all values of first document after merging" do
        expect(master.a_string).to eq(master_copy.a_string)
        expect(master.a_number).to eq(master_copy.a_number)
        expect(master.a_boolean).to eq(master_copy.a_boolean)
        expect(master.array_simple_types).to eq(master_copy.array_simple_types)
        expect(master.a_hash).to eq(master_copy.a_hash)
      end

      # TODO: use timecop for testing time
      # it "update date change" do
      #   expect(master.updated_at).not_to eq(master_copy.updated_at)
      # end
      
      it "delete second document" do
        expect { MyClass.find(slave._id) }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
    
    context "when first document have nil attributes" do
      before do
        master.a_string = nil
        run_regular_merge_method
      end

      it "should replace by second ones" do
        expect(master.a_string).to eq(slave.a_string)
      end
    end
    
    context "when first document have another simple types array" do
      before do
        master.array_simple_types = ["a","totally","different","array"]
        run_regular_merge_method
      end

      it "merge arrays values" do
        expect(master.array_simple_types).to include("different")
      end

      it "remove duplicates" do
        values_count = count_elements_in_array master.array_simple_types 
        expect(values_count["array"]).to eq(1)
      end
    end
    
    context "with arrays of different hashes" do
      it "concatenate" do
        expect{run_regular_merge_method}.to change{master.array_hashes.size}.from(3).to(6)
      end
    end

    context "with arrays of same hashes" do
      before do
        master.array_hashes = slave.array_hashes
      end

      it "merge" do
        expect{run_regular_merge_method}.to_not change{master.array_hashes.size}.from(3).to(6)
      end
    end
    
    # TODO: what's going on in dedupe method?
    # it "should merge the arrays of hashes with custom unique attribute and remove the duplicates if they exist" do
    #   initial_array_size = @A.array_hashes.size
    #     
    #   #keeping the initial size
    #   @B.array_hashes.push({"attribute" => "yes sir"})
    #   @A.merge!(@B,{"array_hashes" => "attribute"})
    # 
    #   @A.array_hashes.size.should == initial_array_size + 2 # Hash with "other_attribute" + hash with "attribute":"yes sir"
    #     
    #   #keeping a backup version
    #   @A_clone = @A.clone
    #   initial_array_size = @A_clone.array_hashes.size
    #   
    #   @A_clone.merge! @A
    #   # same object ids so the duplicates are removed
    #   @A_clone.array_hashes.size.should == initial_array_size
    # end   
    
    context "when first document contain empty string" do
      before do
        master.a_string = ""
        slave.a_string = "yes"
        run_regular_merge_method
      end

      it "overwrite empty string" do
        expect(master.a_string).to eq("yes")
      end
    end 
    
    context "when first document contain empty string and second - nil value" do
      before do
        master.a_string = ""
        slave.a_string = nil
        run_regular_merge_method
      end

      it "not overwrite" do
        expect(master.a_string).to eq("")
      end
    end
    
    context "with inherited object" do
      let(:inherited) { MyIngeritedClass.new }

      it "merge correct" do
        expect {master.merge! inherited}.not_to raise_error
      end
    end

    context "with another random object" do
      let(:random) { MyRandomClass.new }

      it "not merge correct" do
        expect {master.merge! random}.to raise_error
      end
    end

    context "with boolean types" do
      before do
        master.a_boolean = false
        slave.a_boolean = true
      end

      it "merge TrueClass and FalseClass attributes" do
        expect {master.merge! slave}.to_not raise_error
      end
    end

    context "when have association and emmbed" do
      it "double increase association count" do
        expect {master.merge! slave}.to change{master.childs.to_a.count}.from(2).to(4)
      end

      it "double increase embeded count" do
        expect {master.merge! slave}.to change{master.an_embeds.to_a.count}.from(2).to(4)
      end
    end

    context "when validation enable" do
      before do
        slave.validate_string = master.validate_string
      end

      it "raise error for invalid record" do
        expect {master.merge!(slave, true)}.to raise_error
      end
    end
  end
end
