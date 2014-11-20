require 'spec_helper'

describe Sqed::BoundaryFinder::GreenLineFinder do
  # let(:image) { ImageHelpers.standard_cross_green }
  let(:image) { ImageHelpers.four_green_lined_quadrants }
  # image = ImageHelpers.standard_cross_green
  let(:b) {
    # let(:image) { ImageHelpers.standard_cross_green }
    # Sqed::BoundaryFinder::GreenLineFinder.new(image: image)
    Sqed::BoundaryFinder::StageFinder.new(image: image) #, layout: SqedConfig::LAYOUTS::offset_cross
  }
  let(:c) {
    b.boundaries
  }
  # let(:d) { image.crop(c.coordinates[0][0], c.coordinates[0][1], c.coordinates[0][2], c.coordinates[0][3], true) }
  let(:d) { image.crop(*c.for(0), true) }
  # let(:d) {
  #   image.crop(126,86,756,596)
  # }
  # d = image.crop(126,86,756,596)
  let(:e) {
    Sqed::BoundaryFinder::GreenLineFinder.new(image: d)
  }
  # e = Sqed::BoundaryFinder::GreenLineFinder.new(image: d)
  let(:f) {
    e.boundaries
  }
  # f = e.boundaries
  specify 'initial image columns are as expected for :image above' do
    expect(image.columns).to eq(3264)
    expect(image.rows).to eq(2452)
#
    expect(b.boundaries.x_for(0)).to eq(484)
    expect(b.boundaries.y_for(0)).to eq(361)
    expect(b.boundaries.width_for(0)).to eq(2447)
    expect(b.boundaries.height_for(0)).to eq(1890)
#
    expect(d.columns).to eq(2447)
    expect(d.rows).to eq(1890)
  end

  specify 'image cropped to stage boundary is correct size ' do
    # write out the found quadrants
    q = nil
    (0..3).each do |j|
      q = d.crop(*f.for(j), true)
      q.write("q#{j}.jpg")
    end
    expect(q.columns).to eq(1969)   # for quadrant 3
    expect(q.rows).to eq(856)       # for quadrant 3
  end

  # Sanity checking let statements
  specify '#boundaries returns a Sqed::Boundaries instance' do
    expect(image).to be_truthy
    expect(b).to be_truthy
    expect(c).to be_truthy
    expect(d).to be_truthy
    expect(e).to be_truthy
    expect(f).to be_truthy
    expect(b.boundaries.class).to eq(Sqed::Boundaries)
    expect(f.class).to eq(Sqed::Boundaries)
  end

  context 'width and height of a standard cross for the test image should be equal for all' do
    # (0..3).each do |i|
    #   specify "the #{i}th image has width < 504" do
    #     expect(c.width_for(i)).to be < 504
    #   end
    #
    #   specify "the #{i}th image has width < 504" do
    #     expect(c.height_for(i)).to be < 400
    #   end
    # end
  end

  specify 'the 0th image starts at x = 0' do
    expect(f.x_for(0)).to eq(0)
  end

  specify 'the 0th image starts at y = 0' do
    expect(f.y_for(0)).to eq(0)
  end

  specify 'the width of the 0th image is ~1969' do
    expect(f.width_for(0)).to eq(1969)
  end

  specify 'the height of the 0th image is ~1890' do
    expect(f.height_for(0)).to eq(993)
  end

  specify 'the 1th image starts at x = 2022' do
    expect(f.x_for(1)).to eq(2022)
  end

  specify 'the 1th image starts at x = 0' do
    expect(f.y_for(1)).to eq(0)
  end

  specify 'the width of the 1th image is ~425' do
    expect(f.width_for(1)).to eq(425)
  end

  specify 'the height of the 1th image is ~927' do
    expect(f.height_for(1)).to eq(927)
  end

  specify 'the 2th image starts at x = 2022' do
    expect(f.x_for(2)).to eq(2022)
  end

  specify 'the 2th image starts at y = 970' do
    expect(f.y_for(2)).to eq(970)
  end
  specify 'the width of the 2th image is ~425' do
    expect(f.width_for(2)).to eq(425)
  end

  specify 'the height of the 2th image is ~920' do
    expect(f.height_for(2)).to eq(920)
  end

  specify 'the 3th image starts at x = 0' do
    expect(f.x_for(3)).to eq(0)
  end

  specify 'the 3th image starts at y = 1034' do
    expect(f.y_for(3)).to eq(1034)
  end
  specify 'the width of the 3th image is ~1969' do
    expect(f.width_for(3)).to eq(1969)
  end

  specify 'the height of the 3th image is ~856' do
    expect(f.height_for(3)).to eq(856)
  end


end 
