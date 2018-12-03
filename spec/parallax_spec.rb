require 'rainbow'

RSpec.describe Parallax do
  it "has a version number" do
    expect(Parallax::VERSION).not_to be nil
  end

  # it "collects workers output and prints it" do
  #   colors = [ :green, :yellow, :red, :cyan, :violet, :limegreen, :indianred, :magenta ]
  #   collector = Parallax::Collector.new(8)
    
  #   8.times do |i|
  #     fork do
  #       sleep_time = rand(2..7)
  #       color = colors.at rand(colors.count)
  #       worker = Parallax::Worker.new(collector, i)
  #       worker.log Rainbow("[#{i}] I'm gonna sleep for #{sleep_time} seconds..").send(color)
  #       sleep sleep_time
  #       worker.log Rainbow("[#{i}] I'm awake!").send(color)
  #       elements = (0..100).to_a
  #       elements.each do |element|
  #         worker.log "[#{i}] Processing element: #{element}"
  #       end
  #       worker.close
  #     end
  #   end

  #   begin
  #     collector.collect
  #   end until collector.all_workers_terminated?
    
  #   collector.close
  # end

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
    elements = (0..100).to_a
    collector = Parallax.execute elements do |worker, elements_chunk|
      elements_chunk.each do |element|
        worker.store(element * 2)
      end
    end

    expected_result = elements.map { |element| element * 2 }
    expect(collector.workers_data.map(&:last).sort).to match expected_result
  end

end
