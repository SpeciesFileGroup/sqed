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
      expect(s.result).to eq(false)
    end
  end

  context 'with a test image' do
    let(:a) { ImageHelpers.test0_image }
    before {
      s.image = a
    }

    specify '#crop_image' do        #should expand to multiple cases of image border types
      expect(s.crop_image).to be_truthy
      expect(s.stage_image.columns < a.columns).to be(true)
      expect(s.stage_image.rows < a.rows).to be(true)
    end

    specify '#boundaries returns a Sqed::Boundaries instance' do
      s.pattern = :standard_cross
      expect(s.boundaries.class).to eq(Sqed::Boundaries)
    end
  end

  context 'stage image with a border' do
    let(:a) { ImageHelpers.standard_cross_green }
    before {
      s.image = a
      s.crop_image
    }
    specify 'stage boundary is created for standard_ cross_green ~ (100,94, 800, 600)' do
      expect(s.stage_boundary.x_for(0)).to be_within(2).of 100
      expect(s.stage_boundary.y_for(0)).to be_within(2).of 94
      expect(s.stage_boundary.width_for(0)).to be_within(2).of 800
      expect(s.stage_boundary.height_for(0)).to be_within(2).of 600
    end
  end

  context 'offset boundaries from original image ' do
    before(:all) {
      @s = Sqed.new(image: ImageHelpers.crossy_green_line_specimen, pattern: :offset_cross)
      @s.crop_image
      @offset_boundaries = @s.boundaries.offset(@s.stage_boundary)
      wtf = 0
    }
    
    specify "offset and size should match internal found areas " do
      sbx = @s.stage_boundary.x_for(0)
      sby = @s.stage_boundary.y_for(0)

      (0..3).each do |i| 
        # check all the x/y      
        expect(@offset_boundaries.x_for(i)).to eq(@s.boundaries.x_for(i) + sbx)
        expect(@offset_boundaries.y_for(i)).to eq(@s.boundaries.y_for(i) + sby)

        # check all width/heights
        expect(@offset_boundaries.width_for(i)).to eq(@s.boundaries.width_for(i))
        expect(@offset_boundaries.height_for(i)).to eq(@s.boundaries.height_for(i))
      end
    end
  end

end 
