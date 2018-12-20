module Parallax
  module Collectable

    def self.included(base)
      
      # @return [Integer] the number of workers running in parallel.
      attr_accessor :workers_count
      # @return [Array] the result of all workers' store method calls.
      attr_accessor :workers_data
      # @return [Integer] the number of completed worker processes.
      attr_accessor :closed_workers_count
      # @return [IO::Pipe] the receiving stream of data.
      attr_accessor :receiving_stream
      # @return [IO::Pipe] the sending stream of data.
      attr_accessor :sending_stream

      ##
      # Inizializes the collectable object with its needed parameters.
      #
      # @param [Integer] workers_count the number of workers running in parallel.
      #
      # @return [Object] the instance of the including object.
      def initialize_collector(workers_count)
        @workers_count = workers_count
        @closed_workers_count = 0
        @receiving_stream, @sending_stream = IO.pipe
        @workers_data = []
        self
      end

      ##
      # Reads data from the receiving stream.
      #
      # @return [String] the received data.
      def receive
        self.collect @receiving_stream.gets.chomp
      end

      ##
      # Interprets a received message from the worker and
      # executes a method in the collector.
      #
      # @param [String] message the message as a string.
      #
      # @return [Object] the execution of the interpreted method.
      def collect(message)
        worker_index, method, *arguments = eval(message)
        self.send method, worker_index, *arguments
      end

      ##
      # Prints a message from the worker.
      #
      # @param [Integer] worker_index the worker number.
      # @param [String] message the worker message.
      #
      # @return [nil]
      def log(worker_index, message)
        puts message
      end

      ##
      # Saves an object in the workers' data.
      #
      # @param [Integer] worker_index the worker number.
      # @param [Object] object the object.
      #
      # @return [nil]
      def store(worker_index, object)
        workers_data.push [ Time.now, worker_index, object ]
      end

      ##
      # In a worker raises an error, this is rescued and reraised
      # in the collector.
      #
      # @param [Integer] worker_index the worker number.
      # @param [Class] error_class the class of the error.
      # @param [String] error_message the message of the error.
      #
      # @return [nil]
      def rescue(worker_index, error_class, error_message)
        raise error_class, "Worker #{worker_index} Error: #{error_message}"
      end

      ##
      # Closes a worker.
      #
      # @param [Integer] worker_index the worker number.
      #
      # @return [nil]
      def close_worker(worker_index)
        @closed_workers_count += 1
      end

      ##
      # Closes the collector and its data streams.
      #
      # @return [nil]
      def close
        @receiving_stream.close
        @sending_stream.close
      end

      ##
      # Checks if all workers have terminated.
      #
      # return [Boolean] if all workers have terminated.
      def all_workers_terminated?
        @closed_workers_count >= @workers_count
      end
    
    end
    
  end
end
