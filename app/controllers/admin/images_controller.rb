# encoding: utf-8

class Admin::ImagesController < Admin::AdminController
  before_action :find_image, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
    respond_to do |format|
      format.js { render text: @image.to_json, layout: false }
    end
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
    @image.update(image_params)
    respond_to do |format|
      format.json { render text: @image.to_json, layout: false }
    end
  end

  def destroy
  end

  protected

  def image_params
    params.require(:image).permit(:name, :byline, :description, :imagefile, :hotspot, :crop_start, :crop_size)
  end

  def find_image
    @image = Image.find(params[:id])
  end

end
