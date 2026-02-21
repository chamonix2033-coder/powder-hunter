class SelectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @ski_resorts = SkiResort.all.order(name_ja: :asc)
    @selected_resort_ids = current_user.selections.pluck(:ski_resort_id)
    map_data = @ski_resorts.map do |resort|
      {
        id: resort.id,
        name: resort.name_ja.presence || resort.name_en,
        lat: resort.latitude,
        lng: resort.longitude,
        powder_index: resort.cached_powder_index || 0,
        is_selected: @selected_resort_ids.include?(resort.id)
      }
    end

    @map_data_json = map_data.to_json
  end

  def create
    @selection = current_user.selections.build(ski_resort_id: params[:ski_resort_id])
    if @selection.save
      redirect_to selections_path, notice: "スキー場を追加しました"
    else
      redirect_to selections_path, alert: @selection.errors.full_messages.join(", ")
    end
  end

  def destroy
    @selection = current_user.selections.find_by(ski_resort_id: params[:id])
    if @selection&.destroy
      redirect_to selections_path, notice: "スキー場の選択を解除しました"
    else
      redirect_to selections_path, alert: "解除に失敗しました"
    end
  end
end
