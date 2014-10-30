# A Sqed::Result is a wrapper for the results of the
# full process of data extraction from an image.
#
class Sqed::Result

  LAYOUT_SECTION_TYPES.keys.each do |k|
    attr_accessor k
    attr_accessor "#{k}_image"
  end
  

end


