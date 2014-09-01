require 'spec_helper'

describe Sqed::OcrParser do

  let(:image) {ImageHelpers.ocr_image}

  skip 'test for the presence of tesseract installation' do
    # use brew install 
  end
 
  specify 'parser returns text via rtesseract' do
    a = Sqed::OcrParser.new(image)
    expect(a.text).to be_truthy
    expect(a.text).to match(/jump street/)
  end

end 
