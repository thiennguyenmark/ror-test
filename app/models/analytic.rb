class Analytic < ApplicationRecord
  before_destroy :disable_destroy

  private

  def disable_destroy
    errors.add(:base, :undestroyable)
    throw :abort
  end
end
