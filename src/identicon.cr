require "siphash"
require "stumpy_png"

# A Crystal implementation of identicons.
#
# Identicon creates an Identicon, similar to those created by Github.
#
# A title and key are used by siphash to calculate a hash value that is
# then used to create a visual identicon representation.
#
# The identicon is made by creating a left hand side pixel representation
# of each bit in the hash value - this is then mirrored onto the right
# hand side to create an image that we see as a shape.
#
# The grid and square sizes can be varied to create identicons of
# differing size.
#
module Identicon
  VERSION = "0.1.0"

  DEFAULT_BACKGROUND_COLOR = "#00000000"
  DEFAULT_BORDER_SIZE      = 35
  DEFAULT_GRID_SIZE        =  7
  DEFAULT_SQUARE_SIZE      = 50
  DEFAULT_KEY              = "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xAA\xBB\xCC\xDD\xEE\xFF"

  # create an identicon png and save it to the given filename
  #
  # Example:
  #
  # ```crystal
  # Identicon.create_and_save("identicons are great!", "test_identicon.png")
  # ```
  #
  # - *title*           : the string value to be represented as an identicon
  # - *filename*        : the full path and filename to save the identicon png to
  # - *background_color*: (optional) the background color of the identicon in hex notation (e.g. "#ffffff" for white)
  # - *border_size*     : (optional) the size in pixels to leave as an empty border around the identicon image
  # - *grid_size*       : (optional)  the number of rows and columns in the identicon, minimum 4, maximum 9
  # - *square_size*     : (optional) the size in pixels of each square that makes up the identicon
  # - *key*             : (optional) a 16 byte key used by siphash when calculating the hash value
  #
  def self.create_and_save(title : String, filename : String, background_color : String = DEFAULT_BACKGROUND_COLOR, border_size : Int32 = DEFAULT_BORDER_SIZE, grid_size : Int32 = DEFAULT_GRID_SIZE, square_size : Int32 = DEFAULT_SQUARE_SIZE, key : String = DEFAULT_KEY)
    blob = create(title, background_color, border_size, grid_size, square_size, key)
    return false if blob == nil

    File.open(filename, "wb") { |f| f << blob }
  end

  # create an identicon png and return it as a binary string
  #
  # Example:
  # ```crystal
  # Identicon.create("identicons are great!")
  # ```
  #
  # See `#create_and_save` for description of parameters.
  #
  def self.create(title : String, background_color : String = DEFAULT_BACKGROUND_COLOR, border_size : Int32 = DEFAULT_BORDER_SIZE, grid_size : Int32 = DEFAULT_GRID_SIZE, square_size : Int32 = DEFAULT_SQUARE_SIZE, key : String = DEFAULT_KEY)
    raise "key is less than 16 bytes" if key.size < 16
    raise "grid_size must be between 4 and 9" if grid_size < 4 || grid_size > 9
    raise "invalid border size" if border_size < 0
    raise "invalid square size" if square_size < 0

    background_color = StumpyCore::RGBA.from_hex(background_color)

    siphash_key = SipHash::Key.new do |i|
      key.bytes[i]
    end
    hash = SipHash(2, 4).siphash(title, siphash_key)

    canvas = StumpyCore::Canvas.new((border_size * 2) + (square_size * grid_size),
      (border_size * 2) + (square_size * grid_size), background_color)

    # set the foreground color by using the first three bytes of the hash value
    color = StumpyCore::RGBA.from_rgba((hash & 0xff), ((hash >> 8) & 0xff), ((hash >> 16) & 0xff), 0xff)

    # remove the first three bytes that were used for the foreground color
    hash >>= 24

    sqx = sqy = 0
    (grid_size * (grid_size + 1) / 2).times do
      if hash & 1 == 1
        x = border_size + (sqx * square_size)
        y = border_size + (sqy * square_size)

        # left hand side
        draw_rect(canvas, x, y, x + square_size - 1, y + square_size - 1, color)

        # mirror right hand side
        x = border_size + ((grid_size - 1 - sqx) * square_size)
        draw_rect(canvas, x, y, x + square_size - 1, y + square_size - 1, color)
      end

      hash >>= 1
      sqy += 1
      if sqy == grid_size
        sqy = 0
        sqx += 1
      end
    end

    memory_io = IO::Memory.new(canvas.width * canvas.height * 8)
    StumpyPNG.write(canvas, memory_io)
    memory_io.to_s
  end

  # create an identicon png and return it as Base64-encoded string
  #
  # Example:
  # ```crystal
  # Identicon.create_base64("identicons are great!")
  # ```
  #
  # See `#create_and_save` for description of parameters.
  #
  def self.create_base64(title, background_color : String = DEFAULT_BACKGROUND_COLOR, border_size : Int32 = DEFAULT_BORDER_SIZE, grid_size : Int32 = DEFAULT_GRID_SIZE, square_size : Int32 = DEFAULT_SQUARE_SIZE, key : String = DEFAULT_KEY)
    Base64.encode(
      self.create(title, background_color, border_size, grid_size, square_size, key)
    )
  end

  private def self.draw_rect(canvas : StumpyCore::Canvas, x0, y0, x1, y1, color : StumpyCore::RGBA)
    [x0, x1].min.upto([x0, x1].max) do |x|
      [y0, y1].min.upto([y0, y1].max) do |y|
        canvas.set(x, y, color)
      end
    end
  end
end
