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

    bar = ProgressBar.new(range_date.count, :percentage)

    annual_reports_processor = ::AnnualReportProcessorService.new
    range_date.each do |date|
      annual_reports_processor.compute_report_for(date)
      bar.increment!
    end

    puts "\n✅ All annual reports generated."
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
end
