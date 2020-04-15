# Resulting

Resulting is a gem to help with result handling and coordinating validations and
saving of (primarily) ActiveRecord objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resulting'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install resulting

## Usage

There is a common pattern in a rails controller doing something like this:

- Controller action calls a service (or two or three)
- That service returns an object (or two or three)
- If you want to see if it was successful, that service may have its own result
object, or you can check if the object was persisted.
- Maybe the service does that and just returns and object for serialization
(more likely since we should have skinny controllers). But then you have the
same problem.
- Result objects are hard to manage outside a framework explicitly and
ruthlessly designed to use them.

There are of course some very complicated situations, but many situations can be
solved using `Resulting`.

While `Resulting` can be used in any way you see fit, the way I use it is
described below.

### Custom Results

First we create a result object specific to our controller action. The reason
for this is we don't need a result object that is so flexible it is basically an
openstruct, but we want something with a slightly nicer API than a hash.

Additionally, this adds clarity, with a tested class, to the result object. So
anyone looking for what this result contains knows to just look for a result
named after the controller action.

```ruby
class CreateUserAndWidgetResult
  include Resulting::Resultable

  def user
    value[:user]
  end

  def widget
    value[:widget]
  end
end
```

### Controller

Now in our controller, since we know the result looks like, we can simply grab
the relevant objects out of it and set them to instance variables for a view, or
put them into JSON with [JBuilder](https://github.com/rails/jbuilder) or whatever.

We can also just check to see if our result was successful, the simplest API for
a result object.

```ruby
class NewController
  def create
    result = UserAndWidgetCreateService.call(params)
    @user = result.user
    @widget = result.widget

    if result.success?
      redirect_to :show
    else
      render :new
    end
  end
end
```

### Result Object and Handlers

Finally, in our service, we initialize the result object we first defined with
our objects that we need to validate, save, and do whatever on.

Then we call the shortcut `.validate_and_save` method which will validate all
objects, this ensures that all objects will have `errors` even if the first one
fails validation.

If they are all valid, it will call `.save` (not `save!`) on each of them, inside an
`ActiveRecord::Base.transaction`. If all `.save` calls return `true`. Then we
will return a succesful result. If any of them return `false`, we will bail out
early and raise an `ActiveRecord::Rollback` error inside of the transaction.

```ruby
class UserAndWidgetCreateService
  def call(params)
    new_result = CreateResult.success({
      user: User.build(params[:user])
      widget: Widget.build(params[:widget])
      role: Role.build(user: user, widget: widget, role: :admin)
    })

    Resulting.validate_and_save(result)
  end
end
```

## Details

1. [`Resulting::Runner`](#resultingrunner)
     1. [`.run_all`](#run_allresult-method)
     1. [`.run_until_failure`](#run_until_failureresult-method)
     1. [With blocks](#with-blocks)
     1. [Options (`:failure_case`, `:wrapper`)](#options-failure_case-wrapper)
     1. [With Rails](#with-rails)
1. [`Resulting::Handler`](#resultinghandler)
1. [`Resulting::Result`](#resultingresult)
    1. [Constructors (`.new`, `.success`, and `.failure`](#constructors-new-success-failure)
    1. [`.wrap`](#wrap)
    1. [Methods (`#value`, `#success?`, and `#failure?`](#methods-value-success-and-failure)
    1. [Values](#values)
1. [Resulting::Helpers](#resultinghelpers)

## Resulting::Runner

The `Resulting::Runner`'s will take a result object, and if that result is
failing, return immediately. That way you can safely pass the results to any
method that takes them without worrying about acting on a failed result. (It's
almost like a monad, but definitely not a monad).

### `.run_all(result, method:)`

This will call the given `method` on every object in `result.values`. It will
keep track whether or not all calls to `method` on each object were true.

If all calls to `method` were `true`, it will return a successful result.

### `.run_until_failure(result, method:)`

This will call the given `method` on every object in `result.values` UNTIL it
sees a failure. At that point, it will bail out and stop calling the method.

### With Blocks

Both of these methods take an optional block:

- In `run_all`, the block will be run no matter what. The return value of the
block will be `&&`'d with the current success value of calling `method` on all
the values. That new success value will determine whether the call was
successful.
  ```ruby
    Resulting::Runner.run_all(result, method: :validate) do
      # Validate other things
      # return true
    end
  ```
- In `run_until_falure`, the block will be run no matter what. The return value of the
block will be `&&`'d with the current success value of calling `method` on all
the values. That new success value will determine whether the call was
successful.
  ```ruby
    Resulting::Runner.run_until_failure(result, method: :validate) do
      # Save other things
      # return true
    end
  ```

****NOTE: The return value of the block is what is used to determine
success.**** Be mindful of the return value.

### Options (`:failure_case`, `:wrapper`)

`failure_case` is an optional argument. It should be a lambda that describes
what to do at the end if a failure is encountered. By default it's just a lambda
that returns false.

For example, when validating, if all `:validate` calls have returned false, we
just want to return `false`. However, if we are saving, and one of the saves
returns false, we actually want to do `raise ActiveRecord::Rollback`.

Odds are you will either return false or raise some error, but any lambda will
do.

`wrapper` is something that will wrap the whole result handling process. The
common example here would be to wrap all saves in an
`ActiveRecord::Base.transaction` block to ensure we can rollback safely.

### With Rails (`.validate`, `.save`, and `.validate_and_save`)

Most of the time this is used within rails, and as described there are some
things you will commonly want to do.

```ruby
Resulting.validate(param)
```

Is equivalent to:

```ruby
Resulting::Runner.run_all(param, method: :validate)
```

```ruby
Resulting.save(param)
```

Is equivalent to:

```ruby
Resulting::Runner.run_until_failure(
  param,
  method: :save,
  failure_case: -> { raise ActiveRecord::Rollback },
  wrapper: -> { ActiveRecord::Base.method(:transaction) },
)
```

Both of these still take blocks.

Finally, `Resulting.validate_and_save` will just call one after the other. This
one does not take a block, so it assumes you just want to validating everything
and then save it.

## Resulting::Result

This is a generic result class that implements `Resulting::Resultable`.

### Constructors: (`.new`, `.success`, `.failure`)

- `.new(success, value)` stores the value and sets success to the first
parameter
- `.success(value)` stores the value and sets success to true
- `.failure(value)` stores the value and sets success as false

### `.wrap`

`Resulting::Result.wrap` is worth calling out on its own. `Result.wrap(value)`
will do the following:

- If `value` is a result (i.e. implements `Resulting::Resultable`) it returns
the value.
- If `value` is anything else, it will return `Result.success(value)`.

```ruby
$ foo = Object.new
$ result = Resulting::Result.wrap(foo)
$ result
=> #<Resulting::Result:0x00007f91dd072238 @success=true, @value=#<Object:0x00007f91db929950>>
$ Resulting::Result.wrap(result)
=> #<Resulting::Result:0x00007f91dd072238 @success=true, @value=#<Object:0x00007f91db929950>>
```

You can use wrap to ensure you have a result object if you need it.

### Methods: `#value`, `#success?`, and `#failure?`

A result has helper methods, `#success?` and `#failure?` which just check whether
`success` is truthy, and the obj is stored as the `value`.

```ruby
success = obj.validate # => true
result = Resulting::Result.new(success, obj)

result.success? # => true
result.value # => obj
```

### `#values`

`values` returns the `value` collapsed into an array. This variable is iterated
over by the two runner methods.

****NOTE: Resulting assumes any methods calls on the value mutate the value
itself and that it is passed by reference.****

- If `value` is a `Hash`, `values` is `value.values.flatten`
- If `value` is anything else, `values` is `Array(value).flatten`
  - (This will wrap objects in an array, and leave arrays alone.)

When building your own result you can override this to provide different
behavior. You could use this maintain access to an object but not call a method
on it, or to add data you want acted on from a side effect.

```ruby
class MyResult
  def user
    values[:user]
  end

  def hashed_password
    values[:password] # Omit from values, so it's not acted on
  end

  def values
    [user, user.side_effect_record]
  end
end
```

In this case, we have a password (or any object in memory we don't/can't
persist). It will be on the result object so we can do something with it, but by
omitting it from `#values`, we don't have to worry about it being acted on.

In contrast, let's say in our services we create some record as a side effect
which couldn't be created at the time we created the result (this is pretty
contrived, but go with it), then we can add that to the values as something to
be validated, saved, or whatever when the runners process the result.

## Resulting::Helpers

If you include `Resulting::Helpers` in a given class or module, you get the
some nifty helper shortcuts.

```ruby
Success(value) # Equal to Resulting::Result.success(value)
Failure(value) # Equal to Resulting::Result.failure(value)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/dewyze/resulting.
