
# A Sqed::Result is a wrapper for the results of the
# full process of data extraction from an image.
#
class Sqed::Result

  SqedConfig::LAYOUT_SECTION_TYPES.each do |k|
    attr_accessor k
    attr_accessor "#{k}_image".to_sym
  end

  # return [Hash]
  #   a map of layout_section_type => value (if there is a value), 
  #   i.e. all possible parsed text values returned from the parser
  def text
    result = {} 
    SqedConfig::LAYOUT_SECTION_TYPES.each do |k|
      text = self.send(k)
      result.merge!(k => text) if text
    end
    result
  end

  def images
    result = {} 
    SqedConfig::LAYOUT_SECTION_TYPES.each do |k|
      image = self.send("#{k}_image")
      result.merge!(k => image) if image
    end
    result
  end

  def write_images
    images.each do |k, img|
      img.write("tmp/#{k}.jpg")
    end
  end

end


