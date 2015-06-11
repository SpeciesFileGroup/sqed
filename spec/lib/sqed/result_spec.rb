require 'spec_helper'

describe Sqed::Result do
  let(:r) {Sqed::Result.new}

  context "attributes are derived from SqedConfig::LAYOUT_SECTION_TYPES" do

    SqedConfig::LAYOUT_SECTION_TYPES.each do |type|
      specify "##{type}" do 
        expect(r.respond_to?(type.to_sym)).to be_truthy 
      end

      specify "##{type}_image" do 
        expect(r.respond_to?("#{type}_image".to_sym)).to be_truthy 
      end

      specify "##{type} initializes to {}" do
        expect(r.send(type.to_sym)).to eq({}) 
      end
    end
  end

  context 'with a new() result' do
    specify '#text_for(section)' do
      expect(r.text_for(:annotated_specimen)).to eq(nil)
    end

    specify '#barcode_text_for(section)' do
      expect(r.barcode_text_for(:identifier)).to eq(nil)
    end

    specify '#text' do
      expect(r.text).to eq({})
    end

    specify '#images' do
      expect(r.text).to eq({})
    end
  end

end 
