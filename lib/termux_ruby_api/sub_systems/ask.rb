module TermuxRubyApi
  module SubSystems
    class Ask < Base
      def confirm(title: nil, hint: nil, result_type: :text)
        args = owner.generate_args_list([['confirm'],
                                         ['-t', title]
                                         ['-i', hint]
                                        ])
        res = owner.json_api_command('dialog', nil, *args)
        extract_result(res)
      end

      def checkbox(title: nil, result_type: :index, *args)
        args = owner.generate_args_list([['checkbox'],
                                         ['-t', title]
                                         ['-v', args.join(',')]
                                        ])
        res = owner.json_api_command('checkbox', nil, *args)
        return res if result_type = :raw
        res[:values]&.map { |r| extract_result(r) }
      end

      def radio(title: nil, result_type: :index, *args)
        args = owner.generate_args_list([['checkbox'],
                                         ['-t', title]
                                         ['-v', args.join(',')]
                                        ])
        res = owner.json_api_command('checkbox', nil, *args)
        extract_result(res)
      end

      private

      def extract_result(res, result_type)
        return res if result_type == :raw
        res && res[result_type]
      end
    end
  end
end
