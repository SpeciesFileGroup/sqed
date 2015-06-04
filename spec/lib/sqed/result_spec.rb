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
    end
  
  end



end 
