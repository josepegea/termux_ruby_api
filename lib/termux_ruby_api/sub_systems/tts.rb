module TermuxRubyApi
  module SubSystems
    class Tts < TermuxRubyApi::SubSystems::Base
      # Speaks a text through the TTS system
      # @param text [String] the text to be spoken
      # @param engine [String] the engine to use (see #engines)
      # @param language [String] the string code for the language to use
      # @param region [String] the string code for the regional variaion of the selected language
      # @param variant [String] the voice of the selected language
      # @param pitch [Fixnum] the desired pitch: 1 neutral. <1 more grave. >1 more acute
      # @param rate [Fixnum] the desired speak rate. 1 neutral. <1 slower. >1 faster
      # @param stream [String] Android audio stream to use: One of ALARM, MUSIC, NOTIFICATION, RING, SYSTEM, VOICE_CALL

      def speak(text, engine: nil, language: nil, region: nil, variant: nil, pitch: nil, rate: nil, stream: nil)
        args = owner.generate_args_list([['-e', engine&.to_s],
                                         ['-l', language&.to_s],
                                         ['-n', region&.to_s],
                                         ['-v', variant&.to_s],
                                         ['-p', pitch&.to_s],
                                         ['-r', rate&.to_s],
                                         ['-s', stream&.to_s]
                                        ])
        owner.api_command('tts-speak', text, *args)
      end

      # Returns the list of available engines
      # @return [Array <Hash>]
      def engines
        owner.json_api_command('tts-engines')
      end
    end
  end
end
