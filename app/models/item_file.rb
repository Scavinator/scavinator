class ItemFile < ApplicationRecord
  belongs_to :item, optional: true
  belongs_to :item_submission, optional: true

  include FileUploader::Attachment(:file)
end
