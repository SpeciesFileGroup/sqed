module ImageHelpers

  BASE_PATH = '../files/'.freeze

  class << self

    def get_image(file_name)
      Magick::Image.read(File.expand_path(BASE_PATH + file_name, __FILE__)).first
    end

    def of_size(width = 1024, height = 768)
      Magick::Image.new(width, height) { |i|
        i.background_color = 'white'
      }
    end

    # Stage images

    def stage
      get_image 'stage_images/stage.png'
    end

    def t_stage
      get_image 'stage_images/t_stage.png'
    end

    def inverted_t_stage
      get_image 'stage_images/inverted_t_stage.png'
    end

    def left_t_stage
      get_image 'stage_images/left_t_stage.png'
    end

    def cross_green
      get_image 'stage_images/boundary_cross_green.jpg'
    end

    def frost_seven_slot
      get_image 'stage_images/frost_7_slot.jpg'
    end

    def frost_stage
      get_image 'stage_images/frost_stage.jpg'
    end

    def frost_stage_thumb
      get_image 'stage_images/frost_stage_thumb.jpg'
    end

    def frost_stage_medimum
      get_image 'stage_images/frost_stage_medimum.jpg'
    end

    def inhs_stage_7_slot
      get_image 'stage_images/inhs_7_slot3.jpg'
    end

    def inhs_stage_7_slot2
      get_image 'stage_images/inhs_7_slot2.jpg'
    end

    def lep_stage
      get_image 'stage_images/lep_stage.jpg'
    end

    def lep_stage2
      get_image 'stage_images/lep_stage2.jpg'
    end

    def lep_stage3
      get_image 'stage_images/lep_stage3.jpg'
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

    def vertical_offset_cross_red
      get_image 'stage_images/boundary_offset_cross_red.jpg'
    end

    def horizontal_offset_cross_red
      get_image 'stage_images/horizontal_offset_cross.png'
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

    # barcode images

    def datamatrix_barcode_image
      get_image 'barcode_images/datamatrix_barcode.png'
    end

    def code_128_barcode_image
      get_image 'barcode_images/code_128_barcode.png'
    end

    def osuc_datamatrix_barcode_image
      get_image 'barcode_images/osuc_datamatric_barcode.png'
    end

    # label (text) images

    # NOT USED
    def black_stage_green_line_specimen_label
      get_image 'label_iamges/label_images/black_stage_green_line_specimen_label.jpg'
    end

    def readme_text
      get_image 'label_images/readme.png'
    end

    def basic_text_image1
      get_image 'label_images/basic1.png'
    end

    def basic_text_image2
      get_image 'label_images/basic2.png'
    end

    # Real life, black border, no internal boundaries
    def test3_image
      get_image 'test3.jpg'
    end

    def foo3_image
      get_image 'foo3.jpg'
    end

    # misc images

    # Not used
    def slide_scan_image
      get_image 'misc_images/types_8.jpg'
    end
  end
end
