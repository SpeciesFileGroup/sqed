require 'spec_helper'
require 'RMagick'
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

    specify '#stage_boundary' do
      expect(s).to respond_to(:stage_boundary)
    end

    specify '#boundaries' do
      expect(s).to respond_to(:boundaries)
    end

    specify '#auto_detect_border' do
      expect(s).to respond_to(:auto_detect_border)
    end

    specify '#boundary_color' do
      expect(s).to respond_to(:boundary_color)
    end
  end

  context 'initialization' do 
    specify 'without providing a pattern assigns :standard_cross' do
      expect(s.pattern).to eq(:standard_cross)
    end
  end

  context '#result' do
    specify 'without providing an image returns false' do
      expect(s.result).to eq(false)
    end
  end

  # test intent is to just test wrapping functionality, see
  # other tests for specifics on finders
  context '#crop_image (with bordered stage)' do 
    specify 'finds a cropped image smaller than original' do 
      s.image = ImageHelpers.test3_image
      expect(s.crop_image).to be_truthy
      expect(s.stage_image.columns < s.image.columns).to be(true)
      expect(s.stage_image.rows < s.image.rows).to be(true)
    end

    specify 'properly sets stage boundaries ' do
      s.image = ImageHelpers.standard_cross_green
      s.crop_image 
      # ~ (100,94, 800, 600)
      expect(s.stage_boundary.x_for(0)).to be_within(2).of 100
      expect(s.stage_boundary.y_for(0)).to be_within(2).of 94
      expect(s.stage_boundary.width_for(0)).to be_within(2).of 800
      expect(s.stage_boundary.height_for(0)).to be_within(2).of 600
    end
  end

  context 'all together' do
    let(:image) { ImageHelpers.crossy_green_line_specimen }
    let(:pattern) { :offset_cross }
    let(:s) { Sqed.new(image: image, pattern: pattern) }

    specify '#boundaries returns a Sqed::Boundaries instance' do
      # s.pattern = :standard_cross
      expect(s.boundaries.class.name).to eq('Sqed::Boundaries')
    end

    specify '#stage_image returns an Magick::Image' do
      expect(s.stage_image.class.name).to eq('Magick::Image')
    end

    specify '#crop_image returns an Magick::Image' do
      expect(s.crop_image.class.name).to eq('Magick::Image')
    end

    specify '#crop_image returns #stage_image' do
      expect(s.crop_image).to eq(s.stage_image)
    end

    context '#result' do
      let(:r) { s.result }
      specify 'returns a Sqed::Result' do
        expect(r.class.name).to eq('Sqed::Result')
      end

      specify 'with extracted data' do
        expect(r.specimen).to eq('000085067')
      end
    end
  end

  specify "find image, barcode, and text content" do
    bc = Sqed::Extractor.new(boundaries: [0, 0, offset_example.image.columns, @s.image.rows], image: offset_example.image, layout: :offset_cross)
    poc = Sqed::Parser::OcrParser.new(bc.extract_image(offset_boundaries.coordinates[1]))
    expect(poc.text).to eq('000085067')
  end

  specify "find image, barcode, and text content" do
    bc = Sqed::Extractor.new(
      boundaries: [0, 0, @s.image.columns, @s.image.rows],  # TODO, this does nothing / needs to be a boundaries object
      image: @s.image, 
      layout: :offset_cross)
    # ioc = bc.extract_image(@offset_boundaries.coordinates[3])
    # iioc = ioc.crop(384, 140, 1420, 572, true)
    poc = Sqed::Parser::OcrParser.new(bc.extract_image(@offset_boundaries.coordinates[3]).crop(400, 140, 1420, 600, true))
    # expect(poc.text).to eq('000085067')
    ppc = Sqed::Parser::OcrParser.new(ImageHelpers.black_stage_green_line_specimen_label)
    poc.image.write('tmp/poc.jpg')
    ppc.image.write('tmp/ppc.jpg')
    expect(ppc.text).to eq(poc.text)
  end

end
