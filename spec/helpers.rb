module Helpers
  def count_elements_in_array array
    array.inject(Hash.new(0)) {|h,i| h[i] += 1; h }
  end
end
