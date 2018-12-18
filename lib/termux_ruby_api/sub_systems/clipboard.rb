module TermuxRubyApi
  module SubSystems
    class Clipboard < Base
      def set(value)
        owner.api_command('clipboard-set', value)
      end

      def get
        owner.api_command('clipboard-get')
      end
    end
  end
end
