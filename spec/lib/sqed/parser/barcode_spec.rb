require 'spec_helper'

# Test barcodes where generated here: http://www.terryburton.co.uk/barcodewriter/generator/, thanks Terry!
#
# http://metafloor.github.io/bwip-js/demo/demo.html
describe Sqed::Parser::BarcodeParser do

  let(:image) { ImageHelpers.code_128_barcode_image  }
  let(:p) { Sqed::Parser::BarcodeParser.new(image) }
  

  specify '#image' do
    expect(p).to respond_to(:image)
  end

  specify '#barcode' do
    expect(p).to respond_to(:barcode)
  end

  specify '#barcode returns some text' do
    expect(p.barcode).to eq('Count01234567!')
  end

end 

