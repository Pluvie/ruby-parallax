module Parallax
  class Collector
    
    attr_accessor :workers_count
    attr_accessor :workers_data
    attr_accessor :closed_workers_count
    attr_accessor :receiving_stream
    attr_accessor :sending_stream

    def initialize(workers_count)
      @workers_count = workers_count
      @closed_workers_count = 0
      @receiving_stream, @sending_stream = IO.pipe
      @workers_data = []
    end

    def collect
      worker_index, method, *arguments = eval(@receiving_stream.gets.chomp)
      self.send method, worker_index, *arguments
    end

    def log(worker_index, message)
      puts message
    end

    def store(worker_index, object)
      workers_data.push [ Time.now, worker_index, object ]
    end

    def rescue(worker_index, error_class, error_message)
      raise error_class, "Worker #{worker_index} Error: #{error_message}"
    end

    def close_worker(worker_index)
      @closed_workers_count += 1
    end

    def all_workers_terminated?
      @closed_workers_count >= @workers_count
    end

    def close
      @receiving_stream.close
      @sending_stream.close
    end
    
  end
end
