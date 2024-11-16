namespace :lint do
  desc "Run all linters"
  task all: :environment do
    Rake::Task["lint:ruby"].invoke
    Rake::Task["lint:erb"].invoke
    Rake::Task["lint:factories"].invoke
    Rake::Task["lint:reek"].invoke
    Rake::Task["lint:security"].invoke
    # TODO:
    # Rake::Task["lint:js"].invoke
    # Rake::Task["lint:css"].invoke
  end

  desc "Lint Ruby code with RuboCop"
  task ruby: :environment do
    require "rubocop/rake_task"

    RuboCop::RakeTask.new do |task|
      task.config_file = "../../.rubocop.yml"
    end
  end

  desc "Verify factories & traits create valid records"
  task factories: :environment do
    if Rails.env.test?
      conn = ActiveRecord::Base.connection
      conn.transaction do
        FactoryBot.lint traits: true
        raise ActiveRecord::Rollback
      end
    else
      system("bundle exec rake lint:factories RAILS_ENV='test'")
      fail if $?.exitstatus.nonzero?
    end
  end

  desc "Lint ERB templates"
  task erb: :environment do
    sh("bundle exec erb_lint --lint-all")
  end

  desc "Brakeman security checks"
  task security: :environment do
    sh("bundle exec brakeman --no-pager --show-ignored")
  end

  desc "Run Reek code smells"
  task reek: :environment do
    sh("bundle exec reek")
  end

  # desc "TODO"
  # task js: :environment do
  # end

  # desc "TODO"
  # task css: :environment do
  # end
end
