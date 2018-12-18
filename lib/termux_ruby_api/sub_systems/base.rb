module TermuxRubyApi
  module SubSystems
    class Base
      attr_accessor :owner
      
      def initialize(owner)
        @owner = owner
      end
    end
  end
end
