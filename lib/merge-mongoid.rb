require 'mongoid'

module Mongoid
  module Document
    module Mergeable
      
      # Merge a mongoid document into another.
      # A.merge!(B)
      def merge!(another_document, validation_flag = false, arr_of_hash_uniq = {})
        if another_document.nil?
          raise "Cannot merge a nil document."
        elsif (self.class <=> another_document.class).nil?
          raise "Cannot merge two different models."
        elsif (!self.is_a? Mongoid::Document) || (!another_document.is_a? Mongoid::Document)
          raise "Can only merge mongoid documents."
        else 
          # let's merge these documents

          # A.merge!(B)
          #
          # We iterate on B attributes :
          another_document.attributes.keys.each do |key|
            self[key] = merge_attributes(self[key],another_document[key],arr_of_hash_uniq[key])
            #mongoid dirty checks don't always work correctly for arrays and maybe hashes, so we'll give it a little help
            if self[key].is_a? Array
                self.changed_attributes[key] = nil
            elsif self[key].is_a? Hash
                self.changed_attributes[key] = nil
            end 
          end

          another_document.relations.each do |key, value|
            case value.relation.to_s
            when "Mongoid::Relations::Referenced::Many", "Mongoid::Relations::Embedded::Many"
              merge_relations(self, another_document, key)
            else
              # TODO: process another types of associations
              puts "unknown relation type: #{value.relation}"
            end
          end
          
          # saving the A model
          self.save!({validate: validation_flag})
          # delete the B model
          another_document.destroy 
        end
      end
      
      private

      def merge_relations(first, second, key)
        already_presented = first.send(key)
        associated_records = second.send(key)
        associated_records.each do |record|
          first.send(key).push(record) unless already_presented.include? record
        end
      end
      
      def merge_attributes(a, b, hash_uniq_attr = {})
        # we might want to remove this test, and for instance merge the different types in an Array
        if ((a.class != NilClass) && (b.class != NilClass) && (a.class != b.class)) && !(((a.class == TrueClass) && (b.class == FalseClass)) || ((a.class == FalseClass) && (b.class == TrueClass)))
          raise "Can't merge different types : "+a.class.to_s+" and "+b.class.to_s
        else
          if (!a.nil?) && (a.is_a? Array) && (b.is_a? Array)
            # For an Array
            # we concat the values in B array at the end of the A Array (if it's not already included).
            a.concat b
            a = dedupe(a,hash_uniq_attr)
          elsif (!a.nil?) && (a.is_a? Hash) && (b.is_a? Hash)
            # For a Hash
            # recursive call
            b.keys.each do |key|
              a[key] = merge_attributes(a[key],b[key])
            end
          else
            # For Basic types (String, Double, Date, Boolean, etc...)
            # If the attribute is already defined in A and not nil, then we keep its value.
            # Else we copy the value of B into A
            if a.blank? && (!b.blank?)
              a = b
            end
          end
          
          return a 
        end
      end
      
      def dedupe(array, hash_uniq_attr = 'id')
        result = []
        ids = [] #where we store the uniqueness identifier
        array.each_with_index do |value,index|
          if (value.is_a? Hash) && !hash_uniq_attr.blank? && (!value[hash_uniq_attr].nil?)
            if !ids.include? value[hash_uniq_attr]
              ids << value[hash_uniq_attr]
              result << value
            end  
          else
            if !result.include? value
              result << value
            end
          end
        end
        
        result
      end
    end
  end
end
