# Parallax

Parallax gem is a quick and simple framework to Ruby IPC and multi-core parallel execution.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'parallax'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install parallax

## Usage

You can use this gem in many ways.

To execute parallel code with an array of elements, divide the elements in N groups and execute each chunk in one forked process.

```ruby
array = [ 'running', 'code', 'in', 'parallel' ]

Parallax.execute array do |worker, array_chunk|
  array_chunk.each do |element|
    worker.log "[#{worker.index}] #{element}"
  end
end

# Example output with 4 cores:
#   [1] code
#   [3] parallel
#   [0] running
#   [2] in
```

If you need inter-process communication, this can be done by calling `worker.send` and passing a list of arguments. The args are serialized and passed via IO pipe to a `collector` object, which is by default an instance of `Parallax::Collector` class. The collector then parses the args and treats them like a method call where the first arg is the name of the method. In the example above, the collectors calls the `log` method which prints the second arg.

The collector object is returned by the `Parallax.execute` method, so if you need to store each worker processed data you can use the `worker.store` method or implement it in your own custom collector. For example:

```ruby
numbers = (0..100).to_a

collector = Parallax.execute numbers, do |worker, numbers_chunk|
  numbers_chunk.each do |number|
    worker.store number * 2
  end
end

puts collector.workers_data.inspect

# Example output with 4 cores:
#   [ [2018-12-04 08:22:06 +0100, 0, 0],
#     [2018-12-04 08:22:06 +0100, 3, 152],
#     [2018-12-04 08:22:06 +0100, 1, 52],
#     [2018-12-04 08:22:06 +0100, 2, 102],
#     ...
```

Other options you can pass to execute are:
* `processes`: the number of processes in which parallelize the execution. Defaults to `Etc.nprocessors` (which is equal to the number of cores of the current running machine).

Methods available for a `worker` object, which are collected in the `collector` object:
* `log(message)`: prints a message in stdout.
* `store(object)`: stores an object with timestamp and worker index.
* `rescue(error)`: rescues an error from a worker and raises the same error in the collector.
* `close`: closes worker communication with the collector.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Pluvie/parallax.
