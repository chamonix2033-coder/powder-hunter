class Admin::SkiResortsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_ski_resort, only: [:edit, :update, :destroy]

  def index
    @ski_resorts = SkiResort.all.order(created_at: :desc)
  end

  def new
    @ski_resort = SkiResort.new
  end

  def create
    @ski_resort = SkiResort.new(ski_resort_params)
    if @ski_resort.save
      redirect_to admin_ski_resorts_path, notice: 'スキー場を追加しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ski_resort.update(ski_resort_params)
      redirect_to admin_ski_resorts_path, notice: 'スキー場を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ski_resort.destroy
    redirect_to admin_ski_resorts_path, notice: 'スキー場を削除しました。'
  end

  private

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: '管理者権限がありません。'
    end
  end

  def set_ski_resort
    @ski_resort = SkiResort.find(params[:id])
  end

  def ski_resort_params
    params.require(:ski_resort).permit(:name_en, :name_ja, :latitude, :longitude, :elevation_base, :elevation_top)
  end
end
