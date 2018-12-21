require 'rainbow'
require 'active_support/all'

RSpec.describe Parallax do
  it "has a version number" do
    expect(Parallax::VERSION).not_to be nil
  end

  it "collects workers output and prints it" do
    expect {
      colors = [ :green, :yellow, :red, :cyan, :violet, :limegreen, :indianred, :magenta ].sample(Etc.nprocessors)
      collector = Parallax.execute colors do |worker, colors_chunk|
        colors_chunk.each do |color|
          sleep_time = rand(2..7)
          worker.log Rainbow("[#{worker.index}] Sleeping for: #{sleep_time}..").send(color)
          sleep sleep_time
          worker.log Rainbow("[#{worker.index}] I'm awake!").send(color)
        end
      end
    }.to_not raise_error
  end

  it "stores workers output" do
    numbers = (0..100).to_a
    collector = Parallax.execute numbers do |worker, numbers_chunk|
      numbers_chunk.each do |number|
        worker.store number * 2
      end
    end

    expected_result = numbers.map { |number| number * 2 }
    expect(collector.workers_data.map(&:last).sort).to eq expected_result
  end

  it "stores workers output even as complex objects" do
    dates = (15.days.ago.to_date..15.days.since.to_date).to_a
    collector = Parallax.execute dates do |worker, dates_chunk|
      dates_chunk.each do |date|
        worker.store(date - 1.year)
      end
    end

    expected_result = dates.map { |date| date - 1.year }
    expect(collector.workers_data.map(&:last).sort).to eq expected_result
  end

  it "can use a custom collector" do

    class CustomCollector
      include Parallax::Collectable

      attr_accessor :name
      
      def initialize(name)
        @name = name
      end
      
      def store(worker_index, object)
        workers_data.push object
      end
    end

    numbers = (0..100).to_a
    custom_collector = CustomCollector.new('Custom Collector')
    Parallax.execute numbers, collector: custom_collector do |worker, numbers_chunk|
      numbers_chunk.each do |number|
        worker.store number * 2
      end
    end

    expected_result = numbers.map { |number| number * 2 }
    expect(custom_collector.workers_data.sort).to eq expected_result
    expect(custom_collector.name).to eq 'Custom Collector'

  end

end
