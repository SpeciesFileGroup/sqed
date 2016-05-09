require 'spec_helper'

describe Sqed::BoundaryFinder::StageFinder do 
  let(:b) {Sqed::BoundaryFinder::StageFinder.new(target_image: ImageHelpers.cross_green )}

  specify '#is border contains a proc' do
    expect(b.is_border.class).to eq(Proc)
  end 
end
