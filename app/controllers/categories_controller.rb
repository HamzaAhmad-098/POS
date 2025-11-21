# app/controllers/categories_controller.rb
class CategoriesController < ApplicationController
  before_action :require_owner
  
  def index
    @categories = Current.shop.categories
  end

  def new
    @category = Current.shop.categories.new
  end

  def create
    @category = Current.shop.categories.new(category_params)
    
    if @category.save
      redirect_to categories_path, notice: "Category created successfully!"
    else
      render :new
    end
  end

  def edit
    @category = Current.shop.categories.find(params[:id])
  end

  def update
    @category = Current.shop.categories.find(params[:id])
    
    if @category.update(category_params)
      redirect_to categories_path, notice: "Category updated successfully!"
    else
      render :edit
    end
  end

  def destroy
    @category = Current.shop.categories.find(params[:id])
    @category.destroy
    redirect_to categories_path, notice: "Category deleted successfully!"
  end

  private
  
  def category_params
    params.require(:category).permit(:name, :parent_id)
  end
end