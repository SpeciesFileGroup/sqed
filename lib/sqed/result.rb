
# A Sqed::Result is a wrapper for the results of the
# full process of data extraction from an image.
#
class Sqed::Result

  SqedConfig::LAYOUT_SECTION_TYPES.each do |k|
    attr_accessor k
    attr_accessor "#{k}_image".to_sym
  end

end


