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

    specify '#stage_boundary' do
      expect(s).to respond_to(:stage_boundary)
    end

    specify '#boundaries' do
      expect(s).to respond_to(:boundaries)
    end

    specify '#has_border' do
      expect(s).to respond_to(:has_border)
    end

    specify '#boundary_color' do
      expect(s).to respond_to(:boundary_color)
    end
  end

  context 'initialization' do 
    specify 'without providing a pattern assigns :cross' do
      expect(s.pattern).to eq(:cross)
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
      s.image = ImageHelpers.cross_green
      s.crop_image 
      # ~ (100,94, 800, 600)
      expect(s.stage_boundary.x_for(0)).to be_within(2).of 100
      expect(s.stage_boundary.y_for(0)).to be_within(2).of 94
      expect(s.stage_boundary.width_for(0)).to be_within(2).of 800
      expect(s.stage_boundary.height_for(0)).to be_within(2).of 600
    end
  end

  context 'all together, without border' do
    let(:image) { ImageHelpers.frost_stage }
    let(:pattern) { :vertical_offset_cross }
    let(:s) { Sqed.new(image: image, pattern: pattern, has_border: false)  }

    specify '#boundaries returns a Sqed::Boundaries instance' do
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

      context 'extracted data' do
        specify 'text for an :identifier section' do

          r.identifier_image.write('41.jpg')
          expect(r.text_for(:identifier)).to match('000041196')
        end

        specify 'text for an annotated_specimen section' do
          expect(r.text_for(:annotated_specimen)).to match('Saucier Creek')
        end

        specify 'text for a curator_metadata section' do
          expect(r.text_for(:curator_metadata)).to match('Frost Entomological Museum')
        end
      end
    end
  end

  context 'all together, with border' do
    let(:image) { ImageHelpers.greenline_image }
    let(:pattern) { :right_t }
    let(:s) { Sqed.new(image: image, pattern: pattern, has_border: true)  }

    specify '#boundaries returns a Sqed::Boundaries instance' do
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

      context 'extracted data' do
        specify 'text for an :identifier section' do
          r.identifier_image.write('85.jpg')
          expect(r.text_for(:identifier)).to match('000085067')
        end

        specify 'text for a specimen section' do
          expect(r.text_for(:annotated_specimen)).to match('Aeshna')
        end
      end
    end
  end


end
