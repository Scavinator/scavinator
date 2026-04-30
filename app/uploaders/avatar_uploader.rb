# This is a subclass of Shrine base that will be further configured for it's requirements.
# This will be included in the model to manage the file.
require "image_processing/mini_magick"

class AvatarUploader < Shrine
  plugin :pretty_location

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)

    {
      large:  magick.resize_to_limit!(400, 400),
    }
  end
end
