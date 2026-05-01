class Team::ScavHunt::Item::SubmissionController < Team::ScavHunt::Item::BaseController
  before_action :set_submission, except: %i[new create]

  def destroy
    @submission.destroy
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def new
  end

  def create
    submission_params = params.require(:item_submission).permit(:instructions, import_files: [], item_files: [])
    @item.transaction do
      submission = @item.create_item_submission!(**submission_params.slice(:instructions), item_files_attributes: submission_params[:item_files]&.map { |file| { file: file } } || [], submitter_id: @user.id)
      @item.item_files.where(id: submission_params[:import_files]).update_all(item_id: nil, item_submission_id: submission.id)
    end
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def edit
  end

  def update
    @submission.update(params.require(:item_submission).permit(:instructions))
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def attach_file
    file_params = params.require(:item_file).permit(files: [], import_files: [])
    @item.transaction do
      @submission.item_files.create(file_params[:files].map { |file| { file: file } }) if !file_params[:files].nil? && file_params[:files].length > 0
      @item.item_files.where(id: file_params[:import_files]).update_all(item_id: nil, item_submission_id: @submission.id) if file_params[:import_files]
    end
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def detach_file
    @submission.item_files.find(params[:id]).update(item: @submission.item, item_submission: nil)
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  private
    def set_submission
      @submission = @item.item_submission
    end
end
