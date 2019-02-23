module TermuxRubyApi
  module SubSystems
    class Tts < Base
      def speak(value, engine: nil, language: nil, region: nil, variant: nil, pitch: nil, rate: nil, stream: nil)
        args = owner.generate_args_list([['-e', engine&.to_s],
                                         ['-l', language&.to_s],
                                         ['-n', region&.to_s],
                                         ['-v', variant&.to_s],
                                         ['-p', pitch&.to_s],
                                         ['-r', rate&.to_s],
                                         ['-s', stream&.to_s]
                                        ])
        owner.api_command('tts-speak', value, *args)
      end

      def engines
        owner.json_api_command('tts-engines')
      end
    end
  end
end
