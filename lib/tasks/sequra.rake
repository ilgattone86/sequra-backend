desc "Tasks to generate all the sequra data for the code challenge"
namespace :sequra do
  task generate: :environment do
    # First let's drop the db and regenerate everything,
    # this way we can be sure that the data is consistent.
    # This will also seed the db with the merchants and orders.
    Rake::Task["db:drop"].invoke
    Rake::Task["db:setup"].invoke

    # Generate disbursements
    Rake::Task["disbursements:generate_all"].invoke

    # Generate monthly fee compliances
    Rake::Task["monthly_fee_compliances:generate_all"].invoke

    # Generate annual reports
    Rake::Task["annual_reports:generate_all"].invoke
  end
end
