desc "Generate all disbursements for the orders in the db"
namespace :disbursement do
  task generate_all: :environment do
    merchants_count = ::Merchant.count
    if merchants_count.zero?
      puts '🤔 No merchants found, did you seed the database? 🤌🏻 Dont worry, I will do it for you. 🤗'
      Rake::Task["db:seed:replant"].invoke
    end

    orders_count = ::Order.count
    if merchants_count.zero?
      puts '🤔 No orders found, did you seed the database? 🤌🏻 Dont worry, I will do it for you. 🤗'
      Rake::Task["db:seed:replant"].invoke
    end

    puts "\n⏳ Generating disbursements for #{orders_count} orders and #{merchants_count} merchants."

    minimum_order_date = ::Order.minimum(:order_received_at)
    maximum_order_date = ::Order.maximum(:order_received_at)
    range_date = (minimum_order_date..maximum_order_date)

    bar = ProgressBar.new(range_date.count, :percentage)

    disbursement_processor = ::DisbursementProcessorService.new
    (minimum_order_date..maximum_order_date).each do |date|
      disbursement_processor.compute_disbursements_for(date)
      bar.increment!
    end

    puts "\n✅ All disbursements generated."
  end

  task destroy_all: :environment do
    puts "⏳ Deleting all disbursements."
    ::Disbursement.destroy_all
    puts "✅ All disbursements deleted."
  end

  task regenerate_all: :environment do
    Rake::Task["disbursement:destroy_all"].invoke
    Rake::Task["disbursement:generate_all"].invoke
  end
end
