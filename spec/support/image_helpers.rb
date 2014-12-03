module ImageHelpers

  BASE_PATH = '../files/'

  class << self

    def get_image(file_name)
      Image.read(File.expand_path(BASE_PATH + file_name, __FILE__)).first
    end

    # Images

    def test0_image
      get_image('test3.jpg')
    end

    def greenline_image
      get_image 'greenlineimage.jpg'
    end

    def ocr_image
      get_image 'test4.jpg'
    end

    def barcode_image
      get_image 'test_barcode.jpg'
    end

    def labels_image
      get_image 'types_8.jpg'
    end

    def foo3_image
      get_image 'foo3.jpg'
    end

    # Images for boundary tests (otherwise empty)

    def standard_cross_green
      get_image 'boundary_cross_green.jpg'
    end

    def crossy_green_line_specimen
      get_image 'CrossyGreenLinesSpecimen.jpg'
    end

    def black_stage_green_line_specimen
      get_image 'black_stage_green_line_specimen.jpg'
    end

    def offset_cross_red
      get_image 'boundary_offset_cross_red.jpg'
    end

    def right_t_green
      get_image 'boundary_right_t_green.jpg'
    end

    def left_t_yellow
      get_image 'boundary_left_t_yellow.jpg'
    end

    def of_size(width = 1024, height = 768)
       Image.new(width, height) {
        self.background_color = 'white'
      }
    end

  end 

end
