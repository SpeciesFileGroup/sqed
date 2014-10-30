require 'spec_helper'

describe Sqed::Boundaries do

  let(:s) { Sqed::Boundaries.new}
  let(:layout) {{ 0 => :foo, 1 => :bar}}

  specify "#coordinates defaults to a Hash when no layout provided" do
    expect(s.coordinates).to eq({})
  end

  context 'with a layout provided' do
    before {
      s.layout = layout
    }

    specify "coordinates can be initialized after the fact (bad idea likely)" do
      expect(s.initialize_coordinates).to be_truthy
    end

    specify "#coordinates has one coordinate system for each section (key in layout)" do
      s.initialize_coordinates
      expect(s.coordinates.keys.sort).to eq([:bar, :foo])
    end

    specify "#each" do
      s.initialize_coordinates
      s.each do |k,v|
        expect([:foo, :bar].include?(k)).to be(true) 
        expect(v).to eq([nil, nil, nil, nil])
      end
    end
  end

end 
