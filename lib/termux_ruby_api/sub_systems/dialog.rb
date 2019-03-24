module TermuxRubyApi
  module SubSystems
    class Dialog < TermuxRubyApi::SubSystems::Base
      # Shows a dialog asking for a simple text message
      # @param title [String] the title of the dialog
      # @param hint [String] aclaratory text
      # @return [String] the text entered by the user
      def text(title = nil, hint: nil)
        args = owner.generate_args_list([['text'],
                                         ['-t', title],
                                         ['-i', hint]
                                        ])
        single_result(args, :text)
      end

      # Shows a dialog asking for a Yes/No confirmation
      # @param title [String] the title of the dialog
      # @param hint [String] aclaratory text
      # @param result_type [:boolean, :text, raw] How you want the result
      #   :boolean #=> true for "Yes" false for "No"
      #   :text #=> "Yes" or "No"
      #   :raw #=> A parsed JSON object with the result from Termux API
      # @return Depends on @result_type
      def confirm(title = nil, hint: nil, result_type: :boolean)
        args = owner.generate_args_list([['confirm'],
                                         ['-t', title],
                                         ['-i', hint]
                                        ])
        single_result(args, result_type)
      end

      # Shows a dialog asking for a multiple choice question, with checkboxes
      # @param title [String] the title of the dialog
      # @param options [Array <String>] the options the user has to select from
      # @param result_type [:index, :text, raw] How you want the result
      #   :index #=> The index (0 based) of the selected options
      #   :text #=> The texts for the selected options
      #   :raw #=> A parsed JSON object with the result from Termux API
      # @return [Array]
      def checkbox(title = nil, result_type: :index, options:)
        args = owner.generate_args_list([['checkbox'],
                                         ['-t', title],
                                         ['-v', options.join(',')]
                                        ])
        res = owner.json_api_command('dialog', nil, *args)
        return res if result_type == :raw
        res[:values]&.map { |r| extract_result(r, result_type) }
      end

      # Shows a dialog asking for a multiple choice question, with radio buttons
      # @param title [String] the title of the dialog
      # @param options [Array <String>] the options the user has to select from
      # @param result_type [:index, :text, raw] How you want the result
      #   :index #=> The index (0 based) of the selected option
      #   :text #=> The text for the selected option
      #   :raw #=> A parsed JSON object with the result from Termux API
      # @return Depends on the result_type
      def radio(title = nil, result_type: :index, options:)
        args = owner.generate_args_list([[__callee__.to_s],
                                         ['-t', title],
                                         ['-v', options.join(',')]
                                        ])
        single_result(args, result_type)
      end

      # Shows a dialog asking for a multiple choice question, with a spinner
      # @param (see #radio)
      # @return (see #radio)
      alias :spinner :radio

      # Shows a dialog asking for a multiple choice question, with an Android sheet
      # @param (see #radio)
      # @return (see #radio)
      alias :sheet :radio

      # Shows a dialog asking for a calendar date
      # @param title [String] the title of the dialog
      # @param result_type [:date, :text, raw] How you want the result
      #   :date #=> A Ruby Date class instance
      #   :text #=> The String for the selected date
      #   :raw #=> A parsed JSON object with the result from Termux API
      # @return Depends on @result_type
      def date(title = nil, result_type: :date)
        args = owner.generate_args_list([['date'],
                                         ['-t', title]
                                        ])
        single_result(args, result_type)
      end

      # Shows a dialog asking for spoken input, to be converted to text
      # @param title [String] the title of the dialog
      # @param hint [String] aclaratory text
      # @param result_type [:boolean, :text, raw] How you want the result
      #   :text #=> The recognized text
      #   :raw #=> A parsed JSON object with the result from Termux API
      # @return Depends on @result_type
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
          res.present? && res[:text].present? && res[:text].downcase == 'yes'
        when :date
          res && res[:text].presence && Date.parse(res[:text])
        else
          res && res[result_type]
        end
      end
    end
  end
end
