# RspecFuzzyTime

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec_fuzzy_time'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec_fuzzy_time

## Problem

This gem aims to solve the problem of difference in precision between Time-like object of Ruby (minimal fraction is 1 nanosecond) and of databases like PostgreSQL (minimal fraction is 1 microsecond).

This difference leads to failing specs in cases like when you try to compare two Time instances representing the same time value but one living in Ruby memory and another obtained from database.

For instance, this spec

```ruby
RSpec.describe 'ActiveRecord time comparison' do
  it 'considers time from DB and from Ruby equal' do
    time1 = Time.now.getutc
    u = User.first
    u.created_at = time1
    u.save!

    u.reload
    time2 = u.created_at

    expect(time1).to eq(time2)
  end
end
```

will fail like this:

```bash
1) ActiveRecord time comparison considers time from DB and from Ruby equal
     Failure/Error: expect(time1).to eq(time2)
       
       expected: 2015-04-07 22:17:44.891270000 +0000
            got: 2015-04-07 22:17:44.891270434 +0000
       
       (compared using ==)
```

Also this problem is described [here](http://blog.solanolabs.com/rails-time-comparisons-devil-details-etc/) and [here](https://gist.github.com/shime/9930893) and the most mentioned solutions to this are:

* custom matcher [https://gist.github.com/shime/9930893](https://gist.github.com/shime/9930893)
* built-in range matchers [http://stackoverflow.com/a/26207378](http://stackoverflow.com/a/26207378)
* conversion of Time values to string or to integer losing precision and thus ignoring the small fraction difference [http://stackoverflow.com/a/20403290](http://stackoverflow.com/a/20403290)
 
But what if you have such a case?

```ruby
expect(User.last).to have_attributes(
    first_name: "John", 
    last_name: "Smith",
    created_at: sample_created_at
    )
```

You want to `have_attributes` and composable matchers to 'just work' but looks like you will have to remove Time-like attributes from comparison by `have_attributes` and compare them separately using one of pretty ugly approaches described above. Something like this (just a dummy example to show the point):

```ruby
shared_examples 'creating Junk with expected received date' do
  it 'creates Junk with expected publish date' do
    Event.create_from_params(event_params_malformed)
    expect(Junk.last.received_date.to_i).to eq(event_params_malformed.created_at.to_i)
  end
end
    
# ...

it 'should create junk with corresponding attributes of EventParams and correct reason' do
  Event.create_from_params(event_params_malformed)
  expect(Junk.last).to have_attributes(
                         body: event_params_malformed.to_json, 
                         reason: 'malformed event params'
                       )
end

it_behaves_like 'creating Junk with expected received date'
```

## Solution

Instead of using `expect(@some_entity.updated_at.utc).to be_within(1.second).of Time.now` let's make this gap configurable and applied  absolutely transparently for RSpec user! Thus the Time comparison will be performed using any desired precision which should be configured according to your database time format storage precision.

Proceed to the [**Usage**](#usage) section to see how you can do this.

Here's some data on how different databases (which have backends supported by ActiveRecord) deal with precision of dates and times:

* PostgreSQL (8.4, 9.0-9.4): [1 microsecond](http://www.postgresql.org/docs/9.4/static/datatype-datetime.html)
* Sqlite3: Arbitrary precision as an [ISO8601](http://en.wikipedia.org/wiki/ISO_8601#Times) [string](http://www.sqlite.org/datatype3.html) with fractional seconds. ActiveRecord only stores nanoseconds.
* MySQL 5.5: [Discards all fractional seconds](http://dev.mysql.com/doc/refman/5.5/en/time.html) from TIME and DATETIME types.

## <a name="usage"></a>Usage

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec_fuzzy_time/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
