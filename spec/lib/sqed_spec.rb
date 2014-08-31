require 'spec_helper'

describe Sqed do

  let(:s) {Sqed.new}

  context 'attributes' do
    specify '#image' do
      # expect that s.image is a method
      expect(s).to respond_to(:image)
    end

    specify 'Sqed.new(image: file) assigns to image' do
      expect(Sqed.new(image: ImageHelpers.test0_image)).to be_truthy
      a = Sqed.new(image: ImageHelpers.test0_image)
      expect(a.image ==  ImageHelpers.test0_image).to be_truthy
    end
  end
end 
