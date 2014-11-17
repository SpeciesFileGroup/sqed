require 'spec_helper'

describe Sqed::BoundaryFinder do

  specify 'when no image provided, #new raises' do
    expect { Sqed::BoundaryFinder.new() }.to raise_error
  end

  context 'when initiated with an image' do
    let(:b) {Sqed::BoundaryFinder.new(image: ImageHelpers.standard_cross_green )}

    specify '#is border contains a proc' do
      expect(b.is_border.class).to eq(Proc)
    end 

    context 'attributes' do
      specify '#img' do
        expect(b).to respond_to(:img)
      end
    end

    specify '#boundaries' do
      expect(b.boundaries.class).to eq(Sqed::Boundaries)
    end

  end
end 
