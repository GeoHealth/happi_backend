class Occurrence < ActiveRecord::Base
  belongs_to :symptom
  belongs_to :gps_coordinate
  has_many :factor_instances

  validates_presence_of :symptom_id
  validates_presence_of :date

  def as_json(options={})
    super(:include =>[:gps_coordinate])
  end
end
