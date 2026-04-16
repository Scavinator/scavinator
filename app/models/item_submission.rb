class ItemSubmission < ApplicationRecord
  belongs_to :item
  belongs_to :submitter, class_name: 'User'
  has_many :item_files, dependent: :destroy
  accepts_nested_attributes_for :item_files, allow_destroy: true
end
