require 'spec_helper'

describe Sqed do

  let(:s) {Sqed.new}

  context 'attributes' do
    specify '#image' do
      expect(s).to respond_to(:image)
    end

    specify '#pattern' do
      expect(s).to respond_to(:pattern)
    end

    specify '#stage_image' do
      expect(s).to respond_to(:image)
    end
  end

  context 'asking for a result' do
    specify 'without providing an image returns false' do
      s.pattern = {}
      expect(s.result).to eq(false)
    end

    specify 'without providing a pattern returns false' do
      s.image = ImageHelpers.test0_image
      expect(s.result).to eq(false)
    end



  end
end 
