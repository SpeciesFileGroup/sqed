require 'spec_helper'

describe Sqed::WindowCropper do

  let(:wc) {Sqed::WindowCropper.new}
  let(:image) { ImageHelper.test0_image }

  context '.new' do
    specify 'accepts an image' do
      expect(Sqed::WindowCropper.new(image: image)).to be_truthy
    end

    specify 'accepts a method' do
      expect(Sqed::WindowCropper.new(image: image, stage_locator: :default)).to be_truthy
    end

    specify '#method= raises if provided method does not exist' do
      expect{wc.method = 'foo'}.to raise_error
    end
  end

  context '#crop' do
    specify 'can be called with an image present' do
      wc.initial_image = image
      expect(wc.crop).to be_truthy
      expect(wc.cropped_image.class).to eq(Magick::Image)
    end

    specify '#cropped_image is smaller than #initial_image' do
      wc.initial_image = image
      wc.crop
      expect(wc.initial_image.columns >= wc.cropped_image.columns).to be_truthy
      expect(wc.initial_image.rows >= wc.cropped_image.rows).to be_truthy
    end

  end


end 
