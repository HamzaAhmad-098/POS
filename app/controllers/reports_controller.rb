# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @report_type = params[:type] || 'daily'
    
    case @report_type
    when 'daily'
      @sales = Current.shop.sales.where(created_at: @date.all_day)
      @title = "Daily Report - #{@date}"
    when 'monthly'
      @sales = Current.shop.sales.where(created_at: @date.all_month)
      @title = "Monthly Report - #{@date.strftime('%B %Y')}"
    when 'yearly'
      @sales = Current.shop.sales.where(created_at: @date.all_year)
      @title = "Yearly Report - #{@date.year}"
    end
    
    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(@sales), filename: "#{@title}.csv" }
      format.pdf do
        render pdf: @title.parameterize,
               template: "reports/report",
               formats: [:html],
               layout: 'pdf'
      end
    end
  end

  private
  
  def generate_csv(sales)
    CSV.generate do |csv|
      csv << ["Date", "Invoice No", "Customer", "Total", "Payment Method"]
      sales.each do |sale|
        csv << [
          sale.created_at.to_date,
          sale.invoice_no,
          sale.customer&.name,
          sale.total_cents / 100.0,
          sale.payment_method
        ]
      end
    end
  end
end