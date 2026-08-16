# frozen_string_literal: true

# Photo management follows whoever may edit the vehicle itself, so the rule
# lives in exactly one place.
class VehicleImagePolicy < ApplicationPolicy
  def create?  = edit_vehicle?
  def destroy? = edit_vehicle?
  def reorder? = edit_vehicle?
  def main?    = edit_vehicle?

  private

  def edit_vehicle?
    vehicle = record.is_a?(VehicleImage) ? record.vehicle : record
    vehicle.present? && VehiclePolicy.new(user, vehicle).update?
  end
end
