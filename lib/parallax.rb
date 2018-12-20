require 'active_support/core_ext/array'

require 'parallax/version'
require 'parallax/collectable'
require 'parallax/collector'
require 'parallax/worker'

module Parallax

  class << self

    ##
    # Get the default number of workers.
    #
    # @return [Integer] the workers count.
    def workers_count
      Etc.nprocessors
    end
  
    ##
    # Divides the given elements in groups of N and executes
    # each chunk in parallel with the given block.
    #
    # @param [Array] elements processing elements.
    # @param [Hash] options secondary options.
    #
    # @return [Collector] all processes output collector.
    def execute(elements, options = {}, &block)
      processes = options[:processes] || Parallax.workers_count

      if options[:collector].present?
        collector = options[:collector]
      else
        collector = Parallax::Collector.new(processes)
      end
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
        collector.receive
      end
      collector.close
      collector
    end

  end

end
