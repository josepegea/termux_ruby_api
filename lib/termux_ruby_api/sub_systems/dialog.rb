module TermuxRubyApi
  module SubSystems
    class Dialog < Base
      def text(title: nil, hint: nil)
        args = owner.generate_args_list([['text'],
                                         ['-t', title],
                                         ['-i', hint]
                                        ])
        res = owner.json_api_command('dialog', nil, *args)
        extract_result(res)
      end

      def confirm(title: nil, hint: nil, result_type: :text)
        args = owner.generate_args_list([['confirm'],
                                         ['-t', title],
                                         ['-i', hint]
                                        ])
        res = owner.json_api_command('dialog', nil, *args)
        extract_result(res)
      end

      def checkbox(title: nil, result_type: :index, options:)
        args = owner.generate_args_list([['checkbox'],
                                         ['-t', title],
                                         ['-v', options.join(',')]
                                        ])
        res = owner.json_api_command('dialog', nil, *args)
        return res if result_type == :raw
        res[:values]&.map { |r| extract_result(r) }
      end

      def radio(title: nil, result_type: :index, options:)
        args = owner.generate_args_list([['checkbox'],
                                         ['-t', title],
                                         ['-v', options.join(',')]
                                        ])
        res = owner.json_api_command('dialog', nil, *args)
        extract_result(res)
      end

      private

      def extract_result(res, result_type = :text)
        return res if result_type == :raw
        res && res[result_type]
      end
    end
  end
end
