module TermuxRubyApi
  module SubSystems
    class Tts < Base
      def speak(value, engine: nil, language: nil, region: nil, variant: nil, pitch: nil, rate: nil, stream: nil)
        args = []
        args += ['-e', engine.to_s] unless engine.nil?
        args += ['-l', language.to_s] unless language.nil?
        args += ['-n', region.to_s] unless region.nil?
        args += ['-v', variant.to_s] unless variant.nil?
        args += ['-p', pitch.to_s] unless pitch.nil?
        args += ['-r', rate.to_s] unless rate.nil?
        args += ['-s', stream.to_s] unless stream.nil?
        owner.api_command('tts-speak', value, *args)
      end
    end
  end
end
