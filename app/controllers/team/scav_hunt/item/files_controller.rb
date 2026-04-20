class Team::ScavHunt::Item::FilesController < Team::ScavHunt::Item::BaseController
  before_action :set_file, except: [:create]
  allow_authcode_access only: %i[show]

  def show
    # metadata = @file.file.metadata
    # send_file(@file.file.to_io, filename: metadata['filename'], type: metadata['mime_type'])
    (status, headers, body) = @file.file.to_rack_response(disposition: "attachment")
    self.status = status
    self.headers.merge!(headers)
    self.response_body = body
  end

  def destroy
    @file.destroy
    redirect_back_or_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def create
    @item.item_files.create(params.require(:item_file).require(:file).map { |f| { file: f } })
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  private
    def set_file
      @file = ItemFile.where(item: @item).or(ItemFile.where(item_submission_id: @item.item_submission&.id)).find_by(id: request.path_parameters[:id])
    end
end
