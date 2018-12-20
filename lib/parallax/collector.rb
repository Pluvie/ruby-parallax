module Parallax
  class Collector
    
    include Parallax::Collectable

    def initialize(workers_count)
      initialize_collector(workers_count)
    end
    
  end
end
