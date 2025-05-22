desc "Generate all monthly fee compliances for the orders in the db"
namespace :monthly_fee_compliances do
  task generate_all: :environment do
    puts "\n⏳ Generating monthly fee compliances."

    minimum_order_date = ::Order.minimum(:order_received_at)
    maximum_order_date = ::Order.maximum(:order_received_at)

    # Retrieve only one date per month
    range_date = (minimum_order_date..maximum_order_date).each_with_object([]) do |date, obj|
      beginning_of_month = date.beginning_of_month
      obj << beginning_of_month if obj.exclude?(beginning_of_month)
    end

    bar = ProgressBar.new(range_date.count, :percentage)

    monthly_fee_processor = ::MonthlyFeeComplianceProcessorService.new
    range_date.each do |date|
      monthly_fee_processor.compute_fee_compliance_for(date)
      bar.increment!
    end

    puts "\n✅ All monthly fee compliances generated."
  end

  task destroy_all: :environment do
    puts "\n⏳ Destroying all monthly fee compliances."
    ::MonthlyFeeCompliance.destroy_all
    puts "✅ All monthly fee compliances destroyed."
  end

  task regenerate_all: :environment do
    Rake::Task["monthly_fee_compliances:destroy_all"].invoke
    Rake::Task["monthly_fee_compliances:generate_all"].invoke
  end
end
