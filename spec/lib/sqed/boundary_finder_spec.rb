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

  context '.green_border_finder(image: image, sample_subdivision: 10)' do
    specify 'finds the vertical dividing line in a standard cross, with border still present' do
      center =  Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.standard_cross_green)
      expect(center).to be > 492
      expect(center).to be < 504
    end

    specify 'finds the vertical dividing line in a standard cross, with border still present, when more precise' do
      center =  Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.standard_cross_green, sample_cutoff_factor: 1.3)
      expect(center).to be > 492
      expect(center).to be < 504
    end

    specify 'finds the vertical dividing line in a right t green cross, with border still present' do
      center =  Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.right_t_green)
      expect(center).to be > 695
      expect(center).to be < 705 
    end

    specify 'finds the vertical dividing line a real image, with border still present' do
      center =  Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.four_green_lined_quadrants)
      expect(center).to be > 2452
      expect(center).to be < 2495 
    end

    specify 'finds the vertical dividing line a real image, with border still present, with 10x fewer subsamples' do
      center =  Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.four_green_lined_quadrants, sample_subdivision_size: 100 )
      expect(center).to be > 2452
      expect(center).to be < 2495 
    end

    specify 'finds the vertical dividing line a real image, with border still present, with 100x fewer subsamples' do
      center =  Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.four_green_lined_quadrants, sample_subdivision_size: 1000 )
      expect(center).to be > 2452
      expect(center).to be < 2495 
    end

    specify 'FAILS to find the vertical dividing line a real image, with border still present, with 200x fewer subsamples' do
      center =  Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.four_green_lined_quadrants, sample_subdivision_size: 2000 )
      expect(center).to be nil
    end

    specify 'finds the vertical dividing line another real image, with border still present' do
      center = Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.greenline_image)
      expect(center).to be > 2445
      expect(center).to be < 2495
    end

    specify 'finds the vertical dividing line another real image, with border still present, and 20x fewer subsamples' do
      center = Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.greenline_image, sample_subdivision_size: 200)
      expect(center).to be > 2445
      expect(center).to be < 2495
    end

    specify 'finds the vertical dividing line another real image, with border still present, and 100x fewer subsamples' do
      center = Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.greenline_image, sample_subdivision_size: 1000)
      expect(center).to be > 2445
      expect(center).to be < 2495
    end

    specify 'FAILS to find the vertical dividing line in a standard cross, with border still present, when even more precise' do
      center =  Sqed::BoundaryFinder.vertical_green_border_finder(image: ImageHelpers.standard_cross_green, sample_cutoff_factor: 1.2)
      expect(center).to be nil
    end
  end

  context '.predict_center(frequency_hash, samples_taken)' do
    # i is a Hash of position => count (it is unordered, but constructed ordered here in assignment)
    let(:i) { {1 => 1, 2 => 3, 3 => 15, 4 => 14, 5 => 1 }}
    specify 'returns the median position (rounds up)' do
      expect( Sqed::BoundaryFinder.predict_center(i, 12)).to eq(4)
    end

    specify 'returns nil if no count is greater than samples taken' do
      expect( Sqed::BoundaryFinder.predict_center(i, 15)).to eq(nil)
    end
  end
  
  context 'green line finding' do
  end
end 
