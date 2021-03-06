# Operationable

This gem is solving the problem with ActiveRecord callbacks hell.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'operationable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install operationable

## Usage

Call operation at your controllers

```ruby
class EntityController < ApplicationController
  def create
    op = EntityOperation::Create.new(@entity, current_user)

    if op.process
      render json: @entity, status: :created
    else
      render json: { errors: @entity.errors }, status: :unprocessable_entity
    end
  end
end
```

Move you model callbacks to operation


```ruby
module EntityOperation
  class Create < Operationable::Create
    class Builder < Operationable::Builder
      def build
        record
      end
    end

    class Serializer < Operationable::Serializer
      RECORD_FIELDS = [].freeze
      USER_FIELDS = %i(id role email name).freeze
    end

    class Specification < Operationable::Specification
      def should_callback_one
        true
      end
    end

    class Delayer < Operationable::Delayer
      def delay_callback_one
        { wait_until: Date.tomorrow.noon } # or wait
      end
    end

    class Runner < Operationable::Runners::Separate
      def initialize_callbacks
        push_to_queue(:callback_one)
        push_to_queue(:callback_two, queue: :low)
        push_to_queue(:callback_three, queue: :high, job_class_name: MySpecialJob)
        push_to_queue(:callback_four, queue: :high, params: {hello: 123})
      end

      # This is default behaviour, but you can redefine it, to use with other adapter for example
      def perform(job_class_name, args, delayed_params)
        job_class_name.to_s.constantize.set(delayed_params).method(perform_method).call(args)
      end
    end

    class Callback < Operationable::Callback
      def callback_one
        AnotherEntities.update_all(field: 123)
      end
    end
  end
end
```

### Operation

Exiting operations: create, update, destroy or use raw Operationable::Operation.
Operationable::Create(Update, Destory) inherited from Operationable::Operation

### Builder

Builder useful for that things you usually do at before_create/update/destroy callbacks.

### Specification

Specification decides run or not run callback based on boolean value returned from should_ prefixed callback name.
If specification not described, callback will called at any case.

### Runner

Exists two types for Runners - Serial and Separate runner. Serial callbacks will run one after another, at described order.
Separate runners not related one for another and can be run simultaneously.

Serial adapter creates one background job, separate for each callback.

push_to_queue(callback_name, queue_name) if queue_name not passed, callback will run synchronously

Operations work via ActiveJob, so you can use any adapter that you want.

### Delayer

This class process when process job

### Job

I get rid of ActiveJob dependency. So, extend you exting job class with code below

```ruby
class OpJob < ActiveJob::Base
  queue_as do
    arguments.first[:q_options][:queue]
  end

  def perform(q_options:, props:)
    "Operationable::Runners::#{q_options[:type].capitalize}".constantize.call(q_options: q_options, props: props)
  end
end

```

Define global job class name at your initializers (config/initializers/operationable.rb)

```ruby
module Operationable
  module Runners
    class Base
      def job_class
        'OpJob'
      end
    end
  end
end
```

### Serializer

Serializer used to define what values should be passed to job(redis do not accept AR instances or other complex structures).
Also you don't need all record fields should passed to callbacks.

### Callback

Class that contain callback methods, that will called after model saved in runtime or in background

### Validators
TODO: describe validators

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Contributions are welcome!

Contributors:
[korbutvitaliy](https://github.com/korbutvitaliy)
[kirillsuhodolov](https://github.com/KirillSuhodolov)


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
