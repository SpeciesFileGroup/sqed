require 'spec_helper'

describe Sqed::Parser::OcrParser do

  let(:image) { ImageHelpers.readme_text  }
  let(:p) { Sqed::Parser::OcrParser.new(image) }

  specify '#image' do
    expect(p).to respond_to(:image)
  end

  specify '#get_text returns some text' do
    expect(p.get_text).to eq('README.md')
  end

end 
