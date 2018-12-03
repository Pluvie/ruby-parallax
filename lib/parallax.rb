require 'active_support/core_ext/array'

require 'parallax/version'
require 'parallax/collector'
require 'parallax/worker'

module Parallax

  class << self
  
    ##
    # Divides the given elements in groups of N and executes
    # each chunk in parallel with the given block.
    #
    # @param [Array] elements processing elements.
    # @param [Hash] options secondary options.
    #
    # @return [Collector] all processes output collector.
    def execute(elements, options = {}, &block)
      processes = options[:processes] || Etc.nprocessors

      collector = Parallax::Collector.new(processes)
      elements_chunks = elements.in_groups(processes, false)
      processes.times do |worker_index|
        Process.fork do
          begin
            worker = Parallax::Worker.new(collector, worker_index)
            yield worker, elements_chunks[worker_index]
          rescue StandardError => error
            worker.rescue error
          ensure
            worker.close
          end
        end
      end
      
      until collector.all_workers_terminated?
        collector.collect
      end
      collector.close
      collector
    end

  end

end
