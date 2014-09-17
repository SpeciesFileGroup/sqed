
module ImageHelpers

  def self.test0_image
    Image.read(File.expand_path('../files/test3.jpg', __FILE__)).first
  end

  def self.ocr_image
    # Image.read(File.expand_path('../files/test_ocr0.jpg', __FILE__)).first
    Image.read(File.expand_path('../files/test3.jpg', __FILE__)).first
  end

  def self.barcode_image
    Image.read(File.expand_path('../files/test_barcode.jpg', __FILE__)).first
  end

  def self.get_image(path)
    Image.read(path)
  end

end
