require 'test_helper'

class ConversionTest < ActiveSupport::TestCase
	  test "I and X should ever be repeated more than 3 times" do
		  assert_no_match(/I{4,}/i, @units, "too many I in this number")
		  assert_no_match(/X{4,}/i, @units, "too many X in this number")
	  end

		test "V and L should never repeat" do
			assert_no_match(/V{2,}/i, @joined, "too many V in this number")
			assert_no_match(/L{2,}/i, @joined, "too many L in this number")
		end

	test "prok should never come before tegj" do
		assert_no_match(/(VL)/i, @joined, "not a valid combination")
	end

	test "pish can only come before tegj once" do
		assert_no_match(/(XXL)/i, @joined, "not a valid combination")
	end

	test "glob can only come before pish or prok once / and never before tegj" do
		assert_no_match(/(IIV)/i, @joined, "not a valid combination")
		assert_no_match(/(IIX)/i, @joined, "not a valid combination")
		assert_no_match(/(IL)/i, @joined, "not a valid combination")
	end


end