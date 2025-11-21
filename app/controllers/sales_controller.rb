# app/controllers/sales_controller.rb
class SalesController < ApplicationController
  before_action :set_sale, only: [:show, :destroy, :receipt]
  
  def index
    @sales = Current.shop.sales
                    .includes(:user, :customer, sale_items: :product)
                    .order(created_at: :desc)
    @today_sales = Current.shop.sales.where(created_at: Date.current.all_day)
  end

  def new
    @sale = Current.shop.sales.new
    @customers = Current.shop.customers.order(:name)
  end

  def create
    @sale = Current.shop.sales.new(sale_params)
    @sale.user = current_user
    
    ActiveRecord::Base.transaction do
      if @sale.save
        respond_to do |format|
          format.html { 
            redirect_to receipt_sale_path(@sale), 
            notice: "Sale completed successfully! Invoice: #{@sale.invoice_no}" 
          }
          format.json { 
            render json: { 
              success: true, 
              message: "Sale completed successfully!",
              sale_id: @sale.id,
              invoice_no: @sale.invoice_no,
              total: @sale.total_amount,
              redirect_url: receipt_sale_path(@sale)
            }, status: :created
          }
        end
      else
        handle_save_error
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    handle_validation_error(e)
  rescue => e
    handle_general_error(e)
  end

  def show
    @sale_items = @sale.sale_items.includes(:product)
  end

  def receipt
    respond_to do |format|
      format.html
    end
  end

  def destroy
    if @sale.completed?
      ActiveRecord::Base.transaction do
        @sale.update!(status: :refunded)
        redirect_to sales_path, notice: "Sale refunded successfully. Stock has been restored."
      end
    else
      redirect_to sales_path, alert: "Cannot refund this sale."
    end
  rescue => e
    redirect_to sales_path, alert: "Error refunding sale: #{e.message}"
  end

  def product_lookup
    barcode = params[:barcode]&.strip
    
    if barcode.blank?
      return render json: { 
        success: false, 
        message: "Barcode is required" 
      }, status: :bad_request
    end
    
    product = Current.shop.products.find_by(barcode: barcode)
    
    if product
      render json: {
        success: true,
        product: {
          id: product.id,
          name: product.name,
          brand: product.brand,
          selling_price: product.selling_price,
          current_stock: product.current_stock.to_f,
          barcode: product.barcode,
          unit: product.unit
        }
      }
    else
      render json: { 
        success: false, 
        message: "Product not found in inventory",
        barcode: barcode
      }, status: :not_found
    end
  end

  private
  
  def set_sale
    @sale = Current.shop.sales.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to sales_path, alert: "Sale not found" }
      format.json { render json: { success: false, message: "Sale not found" }, status: :not_found }
    end
  end

  def sale_params
    params.require(:sale).permit(
      :customer_id, 
      :payment_method, 
      :discount_cents, 
      :tax_cents, 
      :total_cents,
      sale_items_attributes: [:product_id, :qty, :unit_price_cents, :_destroy]
    )
  end
  
  def handle_save_error
    @customers = Current.shop.customers.order(:name)
    
    respond_to do |format|
      format.html do
        flash.now[:alert] = "Error creating sale: #{@sale.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
      format.json do
        render json: { 
          success: false, 
          message: @sale.errors.full_messages.join(', '),
          errors: @sale.errors.messages
        }, status: :unprocessable_entity
      end
    end
  end
  
  def handle_validation_error(exception)
    @customers = Current.shop.customers.order(:name)
    
    respond_to do |format|
      format.html do
        flash.now[:alert] = "Validation error: #{exception.message}"
        render :new, status: :unprocessable_entity
      end
      format.json do
        render json: { 
          success: false, 
          message: exception.message
        }, status: :unprocessable_entity
      end
    end
  end
  
  def handle_general_error(exception)
    Rails.logger.error("Sale creation error: #{exception.class} - #{exception.message}")
    
    @customers = Current.shop.customers.order(:name)
    
    respond_to do |format|
      format.html do
        flash.now[:alert] = "An unexpected error occurred. Please try again."
        render :new, status: :unprocessable_entity
      end
      format.json do
        render json: { 
          success: false, 
          message: "An unexpected error occurred."
        }, status: :internal_server_error
      end
    end
  end
end