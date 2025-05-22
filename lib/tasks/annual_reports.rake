desc "Generate annual reports"
namespace :annual_reports do
  task generate_all: :environment do
    puts "\n⏳ Generating annual reports."

    minimum_order_date = ::Order.minimum(:order_received_at)
    maximum_order_date = ::Order.maximum(:order_received_at)

    # Retrieve only one date per year
    range_date = (minimum_order_date..maximum_order_date).each_with_object([]) do |date, obj|
      beginning_of_year = date.beginning_of_year
      obj << beginning_of_year if obj.exclude?(beginning_of_year)
    end

    annual_reports_processor = ::AnnualReportProcessorService.new
    range_date.each { |date| annual_reports_processor.compute_report_for(date) }

    print_pretty_table
  end

  task destroy_all: :environment do
    puts "\n⏳ Destroying all annual reports."
    ::AnnualReport.destroy_all
    puts "✅ All annual reports destroyed."
  end

  task regenerate_all: :environment do
    Rake::Task["annual_reports:destroy_all"].invoke
    Rake::Task["annual_reports:generate_all"].invoke
  end

  def print_pretty_table
    table_config = [
      { key: :year, size: "*", title: "Year" },
      { key: :number_of_disbursements, size: "*", title: "Number of disbursements" },
      { key: :amount_disbursed_to_merchants, size: "*", title: "Amount disbursed to merchants" },
      { key: :amount_of_orders_commission_fee, size: "*", title: "Amount of order fees" },
      { key: :number_of_monthly_fees_charged, size: "*", title: "Number of monthly fees charged" },
      { key: :amount_of_monthly_fees_charged, size: "*", title: "Amount of monthly fees charged" }
    ]

    ConsoleTable.define(table_config, title: "Annual reports") do |table|
      ::AnnualReport.all.each do |annual_report|
        table << {
          year: annual_report.year,
          number_of_disbursements: "# #{annual_report.number_of_disbursements}",
          number_of_monthly_fees_charged: "# #{annual_report.number_of_monthly_fees_charged}",
          amount_disbursed_to_merchants: "€ #{annual_report.amount_disbursed_to_merchants}",
          amount_of_monthly_fees_charged: "€ #{annual_report.amount_of_monthly_fees_charged}",
          amount_of_orders_commission_fee: "€ #{annual_report.amount_of_orders_commission_fee}"
        }
      end
    end
  end
end
