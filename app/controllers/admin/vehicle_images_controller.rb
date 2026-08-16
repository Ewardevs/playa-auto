module Admin
  # Photo management for a vehicle. Each action is a small, REST-shaped
  # operation that re-renders the gallery over Turbo, so the grid on screen
  # always reflects what was actually stored.
  class VehicleImagesController < BaseController
    before_action :set_vehicle
    before_action :set_image, only: %i[destroy main]

    def create
      authorize @vehicle, :create?, policy_class: VehicleImagePolicy

      created, failed = attach_files

      if failed.any?
        flash.now[:alert] = t("admin.vehicles.images.invalid", errors: failed.to_sentence)
      elsif created.positive?
        flash.now[:notice] = t("admin.vehicles.images.added", count: created)
      end

      respond_with_gallery
    end

    def destroy
      authorize @image, :destroy?
      @image.destroy!

      flash.now[:notice] = t("admin.vehicles.images.deleted")
      respond_with_gallery
    end

    def main
      authorize @image, :main?
      @image.make_main!

      flash.now[:notice] = t("admin.vehicles.images.main_updated")
      respond_with_gallery
    end

    # Receives the ids in their new order from the sortable controller.
    def reorder
      authorize @vehicle, :reorder?, policy_class: VehicleImagePolicy

      ids = Array(params[:ids]).map(&:to_i)
      Vehicles::ReorderImages.new(@vehicle, ids: ids).call

      head :ok
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn("[images] reorder falló para vehicle=#{@vehicle.id}: #{e.message}")
      head :unprocessable_content
    end

    private

    def set_vehicle
      @vehicle = Vehicle.find_by!(slug: params[:vehicle_id])
    end

    def set_image
      @image = @vehicle.images.find(params[:id])
    end

    def attach_files
      created = 0
      failed  = []

      Array(params[:files]).reject(&:blank?).each do |upload|
        image = @vehicle.images.new(file: upload)

        if image.save
          created += 1
        else
          failed << "#{upload.original_filename} (#{image.errors[:file].to_sentence})"
        end
      end

      [ created, failed ]
    end

    def respond_with_gallery
      @vehicle.reload

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              helpers.dom_id(@vehicle, :gallery),
              Vehicles::ImageGalleryComponent.new(vehicle: @vehicle, editable: true)
            ),
            turbo_stream.update("flash", UI::FlashComponent.new(flash))
          ]
        end
        format.html { redirect_back fallback_location: edit_admin_vehicle_path(@vehicle), status: :see_other }
      end
    end
  end
end
