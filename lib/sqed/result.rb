# A Sqed::Result is a container for the results of the
# the data extraction for the full stage 
#
class Sqed::Result

  SqedConfig::LAYOUT_SECTION_TYPES.each do |k|
    attr_accessor "#{k}_image".to_sym
    attr_accessor k
  end

  def initialize
    SqedConfig::LAYOUT_SECTION_TYPES.each do |k|
      send("#{k}=", {}) 
    end
  end

  # return [String, nil]
  #   the text derived from the OCR parsing of the section
  def text_for(section)
    send(section)[:text] 
  end

  # return [String, nil]
  #   the text derived from the barcode parsing of the section
  def barcode_text_for(section)
    send(section)[:barcode]
  end

  # return [Hash]
  #   a map of layout_section_type => value (if there is a value), 
  #   i.e. all possible parsed text values returned from the parser
  def text
    result = {} 
    SqedConfig::LAYOUT_SECTION_TYPES.each do |k|
      v = self.send(k)
      result.merge!(k => v) if v[:barcode] || v[:text] 
    end
    result
  end

  # return [Hash]
  #   a map of layout_section_type => Rmagick::Image
  def images
    result = {} 
    SqedConfig::LAYOUT_SECTION_TYPES.each do |k|
      image = self.send("#{k}_image")
      result.merge!(k => image) if image
    end
    result
  end

  # return [True]
  #   write the images in #images to tmp/ 
  def write_images
    images.each do |k, img|
      img.write("tmp/#{k}.jpg")
    end
    true
  end

end


