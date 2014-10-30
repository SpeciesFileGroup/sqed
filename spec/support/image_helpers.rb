module ImageHelpers

  def self.test0_image
    Image.read(File.expand_path('../files/test3.jpg', __FILE__)).first
  end

  def self.greenline_image
    Image.read(File.expand_path('../files/greenlineimage.jpg', __FILE__)).first
  end
  def self.ocr_image
    # Image.read(File.expand_path('../files/Quadrant_2_3.jpg', __FILE__)).first
    Image.read(File.expand_path('../files/test4.jpg', __FILE__)).first
  end

  def self.barcode_image
    Image.read(File.expand_path('../files/test_barcode.jpg', __FILE__)).first
  end

  def self.labels_image
    Image.read(File.expand_path('../files/types_8.jpg', __FILE__)).first
  end

  def self.foo3_image
    Image.read(File.expand_path('../../../foo3.jpg', __FILE__)).first
  end

  def self.get_image(path)
    Image.read(path)
  end

end
