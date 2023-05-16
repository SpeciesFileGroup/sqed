require 'spec_helper'

describe Sqed do

  let(:s) { Sqed.new( pattern: :cross) }

  context 'attributes' do

    specify '#metadata_map' do
      expect(s).to respond_to(:metadata_map)
    end

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

    specify '#has_border defaults to `true`' do
      expect(s.has_border).to eq(true)
    end

    specify '#boundary_color defaults to :green' do
      expect(s.boundary_color).to eq(:green)
    end

    specify '#use_thumbnail defaults to `true`' do
      expect(s.use_thumbnail).to eq(true)
    end
  end

  specify 'raises without pattern or boundary_finder provided' do
    expect{Sqed.new}.to raise_error Sqed::Error
  end

  specify '#result without image returns false' do
    expect(s.result).to eq(false)
  end

  # Intent is to just test wrapping functionality, see
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
    let(:s1) { Sqed.new(image: image, pattern: :vertical_offset_cross, has_border: false) }

    specify '#boundaries returns a Sqed::Boundaries instance' do
      expect(s1.boundaries.class.name).to eq('Sqed::Boundaries')
    end

    specify '#stage_image returns an Magick::Image' do
      expect(s1.stage_image.class.name).to eq('Magick::Image')
    end

    specify '#crop_image returns an Magick::Image' do
      expect(s1.crop_image.class.name).to eq('Magick::Image')
    end

    specify '#crop_image returns #stage_image' do
      expect(s1.crop_image).to eq(s1.stage_image)
    end

    context '#result' do
      let(:rz) { s1.result }

      specify 'returns a Sqed::Result' do
        expect(rz.class.name).to eq('Sqed::Result')
      end

      specify '#text_for an :identifier section' do
        expect(rz.text_for(:identifier)).to match('000041196')
      end

      specify '#text_for an :annotated_specimen section' do
        expect(rz.text_for(:annotated_specimen)).to match('Saucier Creek')
      end

      specify '#text_for a :curator_metadata section' do
        expect(rz.text_for(:curator_metadata)).to match(/Frost\s*Entomological\s*Museum/)
      end
    end
  end

  context 'all together, with border' do
    let(:image) { ImageHelpers.greenline_image }
    let(:s2) { Sqed.new(image: image, pattern: :right_t, has_border: true) }

    specify '#boundaries returns a Sqed::Boundaries instance' do
      expect(s2.boundaries.class.name).to eq('Sqed::Boundaries')
    end

    specify '#stage_image returns an Magick::Image' do
      expect(s2.stage_image.class.name).to eq('Magick::Image')
    end

    specify '#crop_image returns an Magick::Image' do
      expect(s2.crop_image.class.name).to eq('Magick::Image')
    end

    specify '#crop_image returns #stage_image' do
      expect(s2.crop_image).to eq(s2.stage_image)
    end

    context '#result' do
      let(:r) { s2.result }
      specify 'returns a Sqed::Result' do
        expect(r.class.name).to eq('Sqed::Result')
      end

      context 'extracted data' do
        # Default settings return nothing, though some combinations of this worked previously
        specify 'text for an :identifier section' do
          expect(r.text_for(:identifier)).to match('000085067')
        end

        specify 'text for a specimen section' do
          expect(r.text_for(:annotated_specimen)).to match('Aeshna')
        end
      end
    end
  end


end
