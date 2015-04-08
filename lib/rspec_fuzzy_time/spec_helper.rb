RSpec.configure do |config|
  config.add_setting :rspec_time_cutoff, default: :nsec # can be :nsec, :usec, :msec
  config.add_setting :rspec_fuzzy_time_enabled, default: false
end