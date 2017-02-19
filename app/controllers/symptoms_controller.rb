class SymptomsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def index
    if params.key?(:name)
      symptoms = Symptom.where('name ilike ?', "%#{params.fetch(:name)}%")
    else
      symptoms = Symptom.all
    end
    render json: {symptoms: symptoms}
  end

  # def occurrences
  #   @symptoms = Symptom.includes(:occurrences).where(occurrences: {user_id: current_user.id})
  #   render json: {symptoms: @symptoms}, :include => [:occurrences], status: 200
  # end
end
