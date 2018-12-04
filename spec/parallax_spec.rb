require 'rainbow'

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
    expect(collector.workers_data.map(&:last).sort).to match expected_result
  end

end
