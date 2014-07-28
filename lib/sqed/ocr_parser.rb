# encoding: UTF-8

# stub 
=begin
  
          # maybe:
          # http://misteroleg.wordpress.com/2012/12/19/ocr-using-tesseract-and-imagemagick-as-pre-processing-task/
           class Sqed::OcrParser::Identifier
              # as parent, but narrow down logic to focus on known patterns

           class Sqed::OcrParser::Labels
=end 

# Given a single image return all text
class Sqed::OcrParser

  attr_accessor :image, :text

  def initialize(image)
    @image = image 
  end

  def text
    # process the images, spit out the text 
    return 'lorum ipsum'
  end

end
