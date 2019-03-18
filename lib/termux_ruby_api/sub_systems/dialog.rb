module TermuxRubyApi
  module SubSystems
    class Dialog < Base
      def text(title = nil, hint: nil)
        args = owner.generate_args_list([['text'],
                                         ['-t', title],
                                         ['-i', hint]
                                        ])
        single_result(args, :text)
      end

      def confirm(title = nil, hint: nil, result_type: :boolean)
        args = owner.generate_args_list([['confirm'],
                                         ['-t', title],
                                         ['-i', hint]
                                        ])
        single_result(args, result_type)
      end

      def checkbox(title = nil, result_type: :index, options:)
        args = owner.generate_args_list([['checkbox'],
                                         ['-t', title],
                                         ['-v', options.join(',')]
                                        ])
        res = owner.json_api_command('dialog', nil, *args)
        return res if result_type == :raw
        res[:values]&.map { |r| extract_result(r, result_type) }
      end

      def radio(title = nil, result_type: :index, options:)
        args = owner.generate_args_list([[__callee__],
                                         ['-t', title],
                                         ['-v', options.join(',')]
                                        ])
        single_result(args, result_type)
      end

      alias :spinner :radio

      alias :sheet :radio

      def date(title = nil, result_type: :date)
        args = owner.generate_args_list([['date'],
                                         ['-t', title]
                                        ])
        single_result(args, result_type)
      end

      def speech(title = nil, hint: nil, result_type: :text)
        args = owner.generate_args_list([['speech'],
                                         ['-t', title],
                                         ['-i', hint]
                                        ])
        single_result(args, result_type)
      end

      private

      def single_result(args, result_type = :raw)
        res = owner.json_api_command('dialog', nil, *args)
        extract_result(res, result_type)
      end

      def extract_result(res, result_type = :text)
        return case result_type
        when :raw
          res
        when :boolean
          res && res[:text] && res[:text].downcase == 'yes'
        when :date
          res && res[:text] && Date.parse(res[:text])
        else
          res && res[result_type]
        end
      end
    end
  end
end
