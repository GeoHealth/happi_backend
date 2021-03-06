class V1::OccurrencesController < V1::BaseController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def create
    @occurrence = OccurrenceFactory.build_from_params(params[:occurrence])
    @occurrence.user = current_user

    begin
      if @occurrence.save
        WeatherFactorInstancesWorker.perform_async(@occurrence.id) unless @occurrence.gps_coordinate.nil?
        ElasticsearchWorker.perform_async(@occurrence.id)
        render json: @occurrence, status: 201
      else
        render :nothing => true, status: 422
      end
    rescue ActiveRecord::InvalidForeignKey
      render :nothing => true, status: 422
    end
  end

  def index
    @occurrences = Occurrence.where(user: current_user).order(:date)
    render json: {occurrences: @occurrences}
  end

  def destroy
    begin
      occurrence = Occurrence.find_by(id: params.fetch(:occurrence_id))
      occurrence.destroy
      render json: occurrence
    rescue ActionController::ParameterMissing
      render :nothing => true, status: 422
    end
  end
end