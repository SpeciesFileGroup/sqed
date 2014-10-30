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

  context 'initialization' do 
    specify 'without providing a pattern assigns :standard_cross' do
      expect(s.pattern).to eq(:standard_cross)
    end
  end

  context 'asking for a result' do
    specify 'without providing an image returns false' do
      s.pattern = {}
      expect(s.result).to eq(false)
    end
  end

  specify '#crop_image' do
    a = ImageHelpers.test0_image
    s.image = a
    expect(s.crop_image).to be_truthy
    expect(s.stage_image.columns < a.columns).to be(true)
    expect(s.stage_image.rows < a.rows).to be(true)
  end
end 
