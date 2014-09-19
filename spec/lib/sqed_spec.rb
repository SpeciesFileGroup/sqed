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
      expect(AutoCropper.new(this_image)).to be_truthy
    end

    specify 'Sqed.new(image: file) assigns to image' do
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


  specify 'all together' do

    eg = Sqed.new(image: ImageHelpers.ocr_image)
    egt = eg.text_from_quadrant(3)

    expect(eg.text_from_quadrant(3)).to match(/Amazon/)
    expect(eg.text_from_quadrant(3)).to match(/Choose your Prime delivery option:/)

    eg = Sqed.new(image: ImageHelpers.ocr_image)
    egb = eg.text_from_quadrant(2)
    u = 1
    expect(egb.barcodes[0]).to eq('CODE-128:013117001040986')
    expect(egb.barcodes[1]).to eq('CODE-128:SDLXHD1QTDVGJ')
    expect(egb.barcodes[2]).to eq('CODE-128:1PPD368LL/A')
    expect(egb.barcodes[3]).to eq('EAN-13:0885909541171')
  end

end 
