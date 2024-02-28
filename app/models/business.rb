class Business < ApplicationRecord
  validates :nombre, presence: true
  validates :correo_electronico, presence: true

  before_save :extract_domain_from_email

  private

  def extract_domain_from_email
    self.sitio_web = correo_electronico.split('@').last if correo_electronico.present?
  end
end
