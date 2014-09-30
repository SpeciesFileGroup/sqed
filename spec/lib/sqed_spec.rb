require 'spec_helper'

describe Sqed do

  let(:s) {Sqed.new}

  context 'attributes' do
    specify '#image' do
      # expect that s.image is a method
      expect(s).to respond_to(:image)
    end

    specify 'autocropper/edgeDetector works' do
      this_image = ImageHelpers.ocr_image
      expect(Sqed::AutoCropper.new(this_image)).to be_truthy
    end

    context 'Sqed.new(image: file) assigns to image' do
      specify 'Sqed.new(image:file) "works"' do
        expect(Sqed.new(image: ImageHelpers.test0_image)).to be_truthy
      end
    end

    specify 'Sqed.new(image: file) assigns to image' do
      a = Sqed.new(image: ImageHelpers.test0_image)
      expect(a.image == ImageHelpers.test0_image).to be(true)
    end
  end

  specify 'zbar barcode decodes' do
    eb = Sqed::BarcodeParser.new(image: ImageHelpers.barcode_image)
    bc = eb.barcodes
    expect(bc).to be_truthy
    expect(bc[0]).to eq('CODE-128:013117001040986')
    expect(bc[1]).to eq('CODE-128:SDLXHD1QTDVGJ')
    expect(bc[2]).to eq('CODE-128:1PPD368LL/A')
    expect(bc[3]).to eq('EAN-13:0885909541171')
    expect(bc[4]).to be(nil)
    expect(bc[5]).to be(nil)
  end

  context "foo" do
    let(:eg) { Sqed.new(image: ImageHelpers.ocr_image) }

    specify 'all together' do
      egt = eg.text_from_quadrant(3)

      expect(egt).to match(/Amazon/)
      expect(egt).to match(/Choose your Prime delivery option:/)

      egb = eg.text_from_quadrant(2)
      u = 1
      expect(egb.barcodes[0]).to eq('CODE-128:013117001040986')
      expect(egb.barcodes[1]).to eq('CODE-128:SDLXHD1QTDVGJ')
      expect(egb.barcodes[2]).to eq('CODE-128:1PPD368LL/A')
      expect(egb.barcodes[3]).to eq('EAN-13:0885909541171')
    end
  end

end 
