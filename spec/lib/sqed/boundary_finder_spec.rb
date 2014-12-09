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

  context '.color_boundary_finder(image: image, sample_subdivision: 10)' do
    specify 'finds the vertical dividing line in a standard cross, with border still present' do
      center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.standard_cross_green)[1]
      expect(center).to be > 492
      expect(center).to be < 504
    end

    specify 'finds the vertical dividing line in a standard cross, with border still present, when more precise' do
      center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.standard_cross_green, sample_cutoff_factor: 0.7)[1]
      expect(center).to be > 492
      expect(center).to be < 504
    end

    specify 'finds the vertical dividing line in a right t green cross, with border still present' do
      center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.right_t_green)[1]
      expect(center).to be > 695
      expect(center).to be < 705 
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
      center =  Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.standard_cross_green, sample_cutoff_factor: 1)
      expect(center).to be nil
    end

    specify 'finds the horizontal dividing line another real image, with border still present' do
      center = Sqed::BoundaryFinder.color_boundary_finder(image: ImageHelpers.greenline_image, scan: :columns)[1]
      expect(center).to be > 1282
      expect(center).to be < 1332 
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
  
end 
