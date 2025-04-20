# frozen_string_literal: true

# Generate bitmap with random rgb values
class RandomBitmap
  BMP_TEMPLATE = 'A2Vv2V'
  DIB_TEMPLATE = 'V3v2V6'
  HEADER_SIZE = 54

  def initialize
    @width = nil
    @height = nil
    @filename = nil
    @row_padding = nil
    @pixel_data_size = nil
    @file_size = nil
  end

  def generate_random_bmp(width: 100, height: 100, filename: 'tmp.bmp')
    set_params(width, height, filename)

    File.open(filename, 'wb') do |f|
      f.write generate_bmp_header
      f.write generate_dib_header
      f.write generate_color_data
      p f.size
    end
  end

  private

  def set_params(width, height, filename)
    @width = width
    @height = height
    @filename = filename
    @byte_width = width * 3
    @row_padding = (4 - @byte_width % 4) % 4
    @pixel_data_size = (@byte_width + @row_padding) * height
    @file_size = HEADER_SIZE + @pixel_data_size
  end

  def generate_bmp_header
    # BMP header data, all values are unsigned except first field which is ASCII
    [
      'BM',       # 2 bytes, identifies bmp/dib file format
      @file_size, # 4 bytes, file size
      0,          # 2 bytes, reserved
      0,          # 2 bytes, reserved
      54,         # 4 bytes, offset to pixel data (bmp header + dib header)
    ].pack(BMP_TEMPLATE)
  end

  def generate_dib_header
    # DIB header (BITMAPINFOHEADER); all values are unsigned, unless stated otherwise
    [
      40,               # 4 bytes, DIB header size
      @width,           # 4 bytes, width in px, signed int
      @height,          # 4 bytes, height in px, signed int
      1,                # 2 bytes, number of color planes (must be 1)
      24,               # 2 bytes, bits per pixel (rgb = 3 bytes = 24 bits)
      0,                # 4 bytes, compression method (0 = no compression)
      @pixel_data_size, # 4 bytes, Image size in bytes
      2835,             # 4 bytes, Horizontal resolution (px/m), signed int
      2835,             # 4 bytes, Vertical resolution (px/m), signed int
      0,                # 4 bytes, number of colors palette (0 defaults to 2^n)
      0                 # 4 bytes, number of important colors, 0 when every color is important
    ].pack(DIB_TEMPLATE)
  end

  def generate_color_data
    # Need mutable, ASCII-8BIT string
    color_data = String.new

    @height.times do
      @byte_width.times do
        color_data << [rand(0..255)].pack('C')
      end
      color_data << "\x00" * @row_padding
    end

    color_data
  end
end


if ARGV[0] == 'test'
  puts "Running test code"
  test = RandomBitmap.new
  test.generate_random_bmp(filename: 'test.bmp')
end
