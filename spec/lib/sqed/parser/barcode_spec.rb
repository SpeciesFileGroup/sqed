require 'spec_helper'

describe Sqed::Parser::BarcodeParser do

  let(:image) { ImageHelpers.standard_cross_green  }
  let(:p) { Sqed::Parser.new(image) }

  specify '#image' do
    expect(p).to respond_to(:image)
  end
end 
