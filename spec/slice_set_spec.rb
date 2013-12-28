# = NMatrix
#
# A linear algebra library for scientific computation in Ruby.
# NMatrix is part of SciRuby.
#
# NMatrix was originally inspired by and derived from NArray, by
# Masahiro Tanaka: http://narray.rubyforge.org
#
# == Copyright Information
#
# SciRuby is Copyright (c) 2010 - 2014, Ruby Science Foundation
# NMatrix is Copyright (c) 2012 - 2014, John Woods and the Ruby Science Foundation
#
# Please see LICENSE.txt for additional copyright notices.
#
# == Contributing
#
# By contributing source code to SciRuby, you agree to be bound by
# our Contributor Agreement:
#
# * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
#
# == slice_set_spec.rb
#
# Test of slice set operations.

require 'pry'
require File.dirname(__FILE__) + "/spec_helper.rb"

describe "Set slice operation" do
  include RSpec::Longrun::DSL

  #after :each do
  #  GC.start
  #end

  [:dense, :yale, :list].each do |stype|
    context "for #{stype}" do
      before :each do
        @m = create_matrix(stype)
      end

      example "set and unset a range of entries with single values" do

        if stype == :yale
          step "verify correct arrangement of Yale IJA and A arrays" do
            @m.extend NMatrix::YaleFunctions
            @m.yale_ija.should == [4,6,8,10,1,2,0,2,0,1]
            @m.yale_a.should   == [0,4,8,0, 1,2,3,5,6,7]
          end
        end

        step "set and reset a single entry" do
          n = @m.clone
          old_val = @m[0,0]
          @m[0,0] = 100
          @m[0,0].should == 100
          @m[0,0] = old_val
          @m.should == n
        end

        if stype == :yale
          n = @m.clone
          step "set a row of entries" do
            n[0,0..2] = 0
            n[0,0..2].to_flat_array.should == [0,0,0]
            n[1,0..2].to_flat_array.should == [3,4,5]
            n[2,0..2].to_flat_array.should == [6,7,8]
          end

          step "set a second row of entries" do
            n[2,0..2] = 0
            n[2,0..2].to_flat_array.should == [0,0,0]
            n[1,0..2].to_flat_array.should == [3,4,5]
          end

          step "reset both rows of entries" do
            n[0,0..2] = [0,1,2]
            n[2,0..2] = [6,7,8]
            n.should == @m
          end
        end

        slice_result_a = NMatrix.new(:dense, 2, 100, @m.dtype).cast(stype)
        slice_result_b = NMatrix.new(:dense, 2, 0,   @m.dtype).cast(stype)
        m = @m.clone

        step "set upper left-hand 2x2 corner to 100" do
          m[0..1,0..1] = 100

          if stype == :yale
            m.yale_ija.should == [4,   6,   8,   10,   1,   2,   0,   2,  0,  1]
            m.yale_a.should   == [100, 100, 8,   0,   100,  2, 100,   5,  6,  7]
          end

          m[0..1,0..1].should == slice_result_a
          m[2,0..1].should == @m[2,0..1]
          m[0..1,2].should == @m[0..1,2]
        end

        step "set upper left-hand 2x2 corner to 0" do
          m[0..1,0..1] = 0
          if stype == :yale
            [4,5,6,8,2,2,0,1].should == m.yale_ija
            [0,0,8,0,2,5,6,7].should == m.yale_a
          end

          m[0..1,0..1].should == slice_result_b
        end

        m = @m.clone
        step "set lower left-hand 2x2 corner to 100" do
          m[1..2,0..1] = 100
          m[1..2,0..1].should == slice_result_a
          m[0,0..1].should == @m[0,0..1]
          m[1..2,2].should == @m[1..2,2]
        end

        step "set lower left-hand 2x2 corner to 0" do
          m[1..2,0..1] = 0
          m[1..2,0..1].should == slice_result_b
        end

        m = @m.clone
        step "set lower right-hand 2x2 corner to 100" do
          m[1..2,1..2] = 100
          m[1..2,1..2].should == slice_result_a
          m[0,1..2].should == @m[0,1..2]
          m[1..2,0].should == @m[1..2,0]
        end

        step "set lower right-hand 2x2 corner to 0" do
          m[1..2,1..2] = 0
          m[1..2,1..2].should == slice_result_b
        end

        m = @m.clone
        step "set upper right-hand 2x2 corner to 100" do
          m[0..1,1..2] = 100
          m[0..1,1..2].should == slice_result_a
          m[2,1..2].should == @m[2,1..2]
          m[0..1,0].should == @m[0..1,0]
        end

        step "set upper right-hand 2x2 corner to 0" do
          m[0..1,1..2] = 0
          m[0..1,1..2].should == slice_result_b
        end
      end

      example "set a range of values to a matrix's contents" do
        x = NMatrix.new(4, stype: :yale, dtype: :int16)
        x.extend NMatrix::YaleFunctions if stype == :yale
        x[1..3,1..3] = @m
        x.to_flat_array.should == [0,0,0,0, 0,0,1,2, 0,3,4,5, 0,6,7,8]
      end

    end
  end

end
