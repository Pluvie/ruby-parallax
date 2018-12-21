module Parallax
  class Worker

    # @return [Object] the collector object.
    attr_accessor :collector
    # @return [Integer] the index of this worker.
    attr_accessor :index

    ##
    # Creates a new worker referred to the specified collector,
    # and with the given index.
    #
    # @param [Collector] the collector.
    # @param [Integer] the index.
    #
    # @return [Worker] the worker.
    def initialize(collector, index)
      @collector = collector
      @index = index
    end

    ##
    # Packs the message before sending it to the sending stream.
    #
    # @params [Array] args the message.
    #
    # @return [String] a string representation of the packed message.
    def pack(*args)
      [ self.index, *args ].to_yaml.gsub("\n", "\t")
    end

    ##
    # Sends the message to the sending stream.
    #
    # @params [Array] args the message.
    #
    # @return [nil]
    def send(*args)
      @collector.sending_stream.puts pack(*args)
    end

    ##
    # Logs the message to the collector.
    #
    # @params [String] message the message.
    #
    # @return [nil]
    def log(message)
      @collector.sending_stream.puts pack(:log, message)
    end

    ##
    # Stores the object in the collector.
    #
    # @param [Object] the object.
    #
    # @return [nil]
    def store(object)
      @collector.sending_stream.puts pack(:store, object)
    end

    ##
    # Rescues an error from the worker and sends it to the collector.
    #
    # @param [Exception] error the error.
    #
    # @return [nil]
    def rescue(error)
      @collector.sending_stream.puts pack(:rescue, error.class, error.message)
    end

    ##
    # Closes the worker and alerts the collector.
    #
    # @return [nil]
    def close
      @collector.sending_stream.puts pack(:close_worker)
    end

  end
end
