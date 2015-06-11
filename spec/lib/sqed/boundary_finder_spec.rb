require 'spec_helper'

describe Sqed::BoundaryFinder do

  specify 'when no image provided, #new raises' do
    expect { Sqed::BoundaryFinder.new() }.to raise_error
  end

  context 'when initiated with an image' do
    let(:b) {Sqed::BoundaryFinder.new(image: ImageHelpers.cross_green, layout: :vertical_offset_cross)}

    context 'attributes' do
      specify '#img' do
        expect(b).to respond_to(:img)
      end
    end

    specify '#boundaries' do
      expect(b.boundaries.class).to eq(Sqed::Boundaries)
    end
  end

  context '.color_boundary_finder(image: image)' do
    context 'with sample_subdivision_size: 10' do
      specify 'finds the vertical dividing line in a standard cross, with border still present' do
        center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.cross_green, sample_subdivision_size: 10 )[1]
        expect(center).to be > 492
        expect(center).to be < 504
      end
      
      specify 'finds the vertical dividing line in a right t green cross, with border still present' do
        center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.right_t_green, sample_subdivision_size: 10)[1]
        expect(center).to be > 695
        expect(center).to be < 705 
      end
    end

    context 'with sample_subdivision_size auto set' do
      specify 'finds the vertical dividing line in a standard cross, with border still present, when more precise' do
        center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.cross_green, sample_cutoff_factor: 0.7)[1]
        expect(center).to be > 492
        expect(center).to be < 504
      end

      specify 'finds the vertical dividing line a real image, with border still present' do
        center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.crossy_green_line_specimen)[1]
        expect(center).to be > 2452
        expect(center).to be < 2495 
      end

      specify 'finds the vertical dividing line a real image, with border still present, with 10x fewer subsamples' do
        center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.crossy_green_line_specimen, sample_subdivision_size: 100 )[1]
        expect(center).to be > 2452
        expect(center).to be < 2495 
      end

      specify 'finds the vertical dividing line a real image, with border still present, with 50x fewer subsamples' do
        center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.crossy_green_line_specimen, sample_subdivision_size: 500 )[1]
        expect(center).to be > 2452
        expect(center).to be < 2495 
      end

      specify 'FAILS to find the vertical dividing line a real image, with border still present, with 200x fewer subsamples' do
        center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.crossy_green_line_specimen, sample_subdivision_size: 2000 )
        expect(center).to be nil
      end

      specify 'finds the vertical dividing line another real image, with border still present' do
        center = Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.greenline_image)[1]
        expect(center).to be > 2445
        expect(center).to be < 2495
      end

      specify 'finds the vertical dividing line another real image, with border still present, and 20x fewer subsamples' do
        center = Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.greenline_image, sample_subdivision_size: 200)[1]
        expect(center).to be > 2445
        expect(center).to be < 2495
      end

      specify 'finds the vertical dividing line another real image, with border still present, and 50x fewer subsamples' do
        center = Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.greenline_image, sample_subdivision_size: 500)[1]
        expect(center).to be > 2445
        expect(center).to be < 2495
      end

      specify 'FAILS to find the vertical dividing line in a standard cross, with border still present, when even more precise' do
        center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.cross_green, sample_cutoff_factor: 1)
        expect(center).to be nil
      end

      specify 'finds the horizontal dividing line another real image, with border still present' do
        center = Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.greenline_image, scan: :columns)[1]
        expect(center).to be > 1282
        expect(center).to be < 1332 
      end
    end
  end

  context '.frequency_stats(frequency_hash, samples_taken)' do
    # i is a Hash of position => count (it is unordered, but constructed ordered here in assignment)
    let(:i) { {1 => 1, 2 => 3, 3 => 15, 4 => 14, 5 => 13 }}
    specify 'returns the median position (rounds up)' do
      expect( Sqed::BoundaryFinder.frequency_stats(i, 12)).to eq([3, 4, 5])
    end

    specify 'returns nil if no count is greater than samples taken' do
      expect( Sqed::BoundaryFinder.frequency_stats(i, 15)).to eq(nil)
    end
  end

  context 'offset boundaries from crossy_black_line_specimen image ' do
    before(:all) {
      @s = Sqed.new(image: ImageHelpers.crossy_black_line_specimen, pattern: :vertical_offset_cross, boundary_color: :black)
      @s.crop_image
      @offset_boundaries = @s.boundaries.offset(@s.stage_boundary)
      true
    }

    ##**** actually fails (?!)
    specify "offset and size should match internal found areas " do     
      sbx = @s.stage_boundary.x_for(0)
      sby = @s.stage_boundary.y_for(0)

      sl =  @s.boundaries.coordinates.length  # may be convenient to clone this model for other than 4 boundaries found
      expect(sl).to eq(4)    #for offset cross pattern and valid image
      expect(@s.boundaries.complete).to be(true)
      expect(@offset_boundaries.complete).to be(true)
      (0..sl - 1).each do |i|
        # check all the x/y
        expect(@offset_boundaries.x_for(i)).to eq(@s.boundaries.x_for(i) + sbx)
        expect(@offset_boundaries.y_for(i)).to eq(@s.boundaries.y_for(i) + sby)

        # check all width/heights
        expect(@offset_boundaries.width_for(i)).to eq(@s.boundaries.width_for(i))
        expect(@offset_boundaries.height_for(i)).to eq(@s.boundaries.height_for(i))
      end
    end
  end

  context 'offset boundaries from black_green_line_specimen image ' do
    before(:all) {
      @s = Sqed.new(image: ImageHelpers.black_stage_green_line_specimen, pattern: :vertical_offset_cross)
      @s.crop_image
      @offset_boundaries = @s.boundaries.offset(@s.stage_boundary)
      true 
    }

    specify "offset and size should match internal found areas " do
      sbx = @s.stage_boundary.x_for(0)
      sby = @s.stage_boundary.y_for(0)

      sl =  @s.boundaries.coordinates.count  # may be convenient to clone this model for other than 4 boundaries found
      expect(sl).to eq(4)    #for offset cross pattern and valid image
      expect(@s.boundaries.complete).to be(true)
      expect(@offset_boundaries.complete).to be(true)
      (0..sl - 1).each do |i|
        # check all the x/y
        expect(@offset_boundaries.x_for(i)).to eq(@s.boundaries.x_for(i) + sbx)
        expect(@offset_boundaries.y_for(i)).to eq(@s.boundaries.y_for(i) + sby)

        # check all width/heights
        expect(@offset_boundaries.width_for(i)).to eq(@s.boundaries.width_for(i))
        expect(@offset_boundaries.height_for(i)).to eq(@s.boundaries.height_for(i))
      end
    end
  end 

  context 'offset boundaries from original red_line image ' do
    before(:all) {
      @s = Sqed.new(image: ImageHelpers.vertical_offset_cross_red, pattern: :right_t, boundary_color: :red)
      @s.crop_image
      @offset_boundaries = @s.boundaries.offset(@s.stage_boundary)
    }

    specify "offset and size should match internal found areas " do
      sbx = @s.stage_boundary.x_for(0)  # only a single boundary
      sby = @s.stage_boundary.y_for(0)
      pct = 0.02

      sl =  @s.boundaries.coordinates.count 
      expect(sl).to eq(3)   
      expect(@s.boundaries.complete).to be(true)
      expect(@offset_boundaries.complete).to be(true)
      expect(@s.stage_boundary.width_for(0)).to be_within(pct*800).of(800)
      expect(@s.stage_boundary.height_for(0)).to be_within(pct*600).of(600)
      (0..sl - 1).each do |i|
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
