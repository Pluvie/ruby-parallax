module Parallax
  class Worker

    attr_accessor :receiver
    attr_accessor :index

    def initialize(receiver, index)
      @receiver = receiver
      @index = index
    end

    def pack(*args)
      [ self.index, *args ].inspect
    end

    def send(*args)
      @receiver.sending_stream.puts pack(*args)
    end

    def log(message)
      @receiver.sending_stream.puts pack(:log, message)
    end

    def store(object)
      @receiver.sending_stream.puts pack(:store, object)
    end

    def rescue(error)
      @receiver.sending_stream.puts pack(:rescue, error.class, error.message)
    end

    def close
      @receiver.sending_stream.puts pack(:close_worker)
    end

  end
end
