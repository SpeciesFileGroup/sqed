module ImageHelpers

  BASE_PATH = '../files/'

  class << self

    def get_image(file_name)
      Magick::Image.read(File.expand_path(BASE_PATH + file_name, __FILE__)).first
    end
    
    def of_size(width = 1024, height = 768)
       Magick::Image.new(width, height) {
        self.background_color = 'white'
      }
    end

    # Stage images 

    def standard_cross_green
      get_image 'stage_images/boundary_cross_green.jpg'
    end

    def crossy_green_line_specimen
      get_image 'stage_images/CrossyGreenLinesSpecimen.jpg'
    end
    def crossy_black_line_specimen
      get_image 'stage_images/CrossyBlackLinesSpecimen.jpg'
    end

    def black_stage_green_line_specimen
      get_image 'stage_images/black_stage_green_line_specimen.jpg'
    end

    def black_stage_green_line_specimen_label
      get_image 'stage_images/label_images/black_stage_green_line_specimen_label.jpg'
    end

    def offset_cross_red
      get_image 'stage_images/boundary_offset_cross_red.jpg'
    end

    def right_t_green
      get_image 'stage_images/boundary_right_t_green.jpg'
    end

    def left_t_yellow
      get_image 'stage_images/boundary_left_t_yellow.jpg'
    end

    def greenline_image
      get_image 'stage_images/greenlineimage.jpg'
    end

    # Barcode images

    def barcode_image
      get_image 'barcode_images/test_barcode.jpg'
    end

    # Text test images

    def test0_image
      get_image('test3.jpg')
    end

    def ocr_image
      get_image 'test4.jpg'
    end

    def foo3_image
      get_image 'foo3.jpg'
    end

    # misc images

    def labels_image
      get_image 'misc_images/types_8.jpg'
    end


  end 

end
