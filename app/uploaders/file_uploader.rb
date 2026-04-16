# This is a subclass of Shrine base that will be further configured for it's requirements.
# This will be included in the model to manage the file.

class FileUploader < Shrine
  plugin :pretty_location

  def generate_location(io, record: nil, **context)
    if record.is_a?(ItemFile) && !record.id.nil?
      item = record.item || record.item_submission.item
      if item.list_category_id
        item_string = "#{item.list_category_id}-#{item.number}"
      else
        item_string = item.number
      end
      "item_submission_uploads/team_scav_hunt/#{item.team_scav_hunt.id}/#{item_string}/#{record.id}-#{context[:metadata]["filename"]}"
    else
      pretty_location(io, record: record, **context)
    end
  end
end
