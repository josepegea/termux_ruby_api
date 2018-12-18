module TermuxRubyApi
  module SubSystems
    class Tts < Base
      def speak(value)
        owner.api_command('tts-speak', value)
      end
    end
  end
end
