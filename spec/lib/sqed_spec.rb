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

    specify 'Sqed.new(image: file) assigns to image' do
      specify 'Sqed.new(image:file) "works"' do
        expect(Sqed.new(image: ImageHelpers.test0_image)).to be_truthy
      end
    end

    specify 'green line parser does something' do
      this_image = ImageHelpers.greenline_image
      cropped_image = Sqed::AutoCropper.new(this_image).img
      a = Sqed::GreenLineFinder.new(cropped_image)
      b = 0
    end

    specify 'Sqed.new(image: file) assigns to image' do
      a = Sqed.new(image: ImageHelpers.test0_image)
      expect(a.image == ImageHelpers.test0_image).to be(true)
    end
  end

  specify 'zbar barcode decodes' do
    eb = Sqed::BarcodeParser.new(image: ImageHelpers.barcode_image)  # was barcode_image
    bc = eb.barcodes
    expect(bc).to be_truthy
    expect(bc[2]).to eq('CODE-128:013117001040986')
    expect(bc[3]).to eq('CODE-128:SDLXHD1QTDVGJ')
    expect(bc[4]).to eq('CODE-128:1PPD368LL/A')
    expect(bc[5]).to eq('EAN-13:0885909541171')
    expect(bc[6]).to eq('EAN-13:885909270334')
    expect(bc[7]).to be(nil)
  end

  specify 'INHS specimen labels' do
    eg = Sqed.new(image: ImageHelpers.labels_image)
    # eg = Sqed.new(image: ImageHelpers.foo3_image)
    eg.image.rotate!(270.0)
    eg.image.write('foo5.jpg')
    egt = eg.text_from_quadrant(3)
    expect(egt).to match(/529 234/)
  end

  context "foo" do
    let(:eg) { Sqed.new(image: ImageHelpers.ocr_image) }

    specify 'all together' do
      # eg = Sqed.new(image: ImageHelpers.ocr_image)
      egt = eg.text_from_quadrant(3)

      expect(egt).to match(/Designed by Apple in California/)
      expect(egt).to match(/8 85909 27035/)
      expect(egt).to match(/EASY/)
      expect(eg.text_from_quadrant(3)).to match(/013‘1700104U986/)  #ACTUALLY 013117001040986

      eg = Sqed.new(image: ImageHelpers.ocr_image)
      egb = eg.text_from_quadrant(2)
      u = 1  #pre-test breakpoint
      expect(egb.barcodes[0]).to eq('QR-Code:http://youtu.be/h9fkPPp8Y1c')
      expect(egb.barcodes[1]).to eq('EAN-13:0885909270354')
      expect(egb.barcodes[2]).to eq('CODE-128:013117001040986')
      expect(egb.barcodes[3]).to eq('CODE-128:SDLXHD1QTDVGJ')
      expect(egb.barcodes[4]).to eq('CODE-128:1PPD368LL/A')
      expect(egb.barcodes[5]).to eq('EAN-13:0885909541171')
      expect(egb.barcodes[6]).to be(nil)
    end
  end
end 
