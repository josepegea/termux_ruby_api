require 'json'
require 'date'
require 'time'
require_relative 'sub_systems'
require 'shellwords'
require 'open3'

require 'pry'

module TermuxRubyApi

  class CommandError < StandardError
    attr_accessor :status, :stderr

    def initialize(status: nil, stderr: nil)
      @status = status
      @stderr = stderr
    end
  end

  class Base

    # Returns the `clipboard` subsystem
    # @return [TermuxRubyApi::SubSystems::Clipboard]
    def clipboard
      @clipboard ||= TermuxRubyApi::SubSystems::Clipboard.new(self)
    end

    # Returns the `tts` subsystem
    # @return [TermuxRubyApi::SubSystems::Tts]
    def tts
      @tts ||= TermuxRubyApi::SubSystems::Tts.new(self)
    end

    # Returns the `call_log` subsystem
    # @return [TermuxRubyApi::SubSystems::CallLog]
    def call_log
      @call_log ||= TermuxRubyApi::SubSystems::CallLog.new(self)
    end

    # Returns the `location` subsystem
    # @return [TermuxRubyApi::SubSystems::Location]
    def location
      @location ||= TermuxRubyApi::SubSystems::Location.new(self)
    end

    # Returns the `sms` subsystem
    # @return [TermuxRubyApi::SubSystems::Sms]
    def sms
      @sms ||= TermuxRubyApi::SubSystems::Sms.new(self)
    end

    # Returns the `sensor` subsystem
    # @return [TermuxRubyApi::SubSystems::Sensor]
    def sensor
      @sensor ||= TermuxRubyApi::SubSystems::Sensor.new(self)
    end

    # Returns the `dialog` subsystem
    # @return [TermuxRubyApi::SubSystems::Dialog]
    def dialog
      @dialog ||= TermuxRubyApi::SubSystems::Dialog.new(self)
    end

    # General executor of Termux API commands
    # @param command [String] the termux command to execute (except the `termux-` prefix.
    # @param stdin [String, nil] If not nil, the contents of `stdin` are passed as STDIN to the command
    # @param args The rest of the arguments are passed verbatim to the executed command.
    # @return [String] the STDOUT of the executed command
    def api_command(command, stdin = nil, *args)
      command, args = prepare_command_args(command, args)
      stdout, stderr, status = Open3.capture3(command, *args, stdin_data: stdin.to_s)
      raise CommandError.new(status: status, stderr: stderr) unless status.success?
      stdout
    end

    # Executes a Termux API command returning the results parsed as JSON
    # @param (see #api_command)
    # @return native Ruby classes parsed from JSON
    # @note JSON objects are converted to ActiveSupport::HashWithIndifferentAccess
    def json_api_command(command, stdin = nil, *args)
      res = api_command(command, stdin, *args)
      return res if res.nil? || res == ''
      JSON.parse(res, symbolize_names: true, object_class: ActiveSupport::HashWithIndifferentAccess)
    end

    # Executes a Termux API command and streams its results, line by line to the provided block
    # @param (see #api_command)
    # If a block is given, each new line output by the executed command is yielded to the block
    # If a block is not given, it returns the output stream and the wait thread.
    # @return [nil, [Io,Thread]]
    def streamed_api_command(command, stdin = nil, *args, &block)
      command, args = prepare_command_args(command, args)
      i, o, t = Open3.popen2(command, *args)
      i.puts(stdin) unless stdin.blank? # If we have any input, send it to the child
      i.close                           # Afterwards we can close child's stdin
      if block_given?
        o.each_line do |line|
          yield line
        end
        o.close
        raise "#{command} failed" unless t.value.success?
      else
        return o, t # The caller has to close o and wait for t
      end
    end

    # Executes the Termux API command and streams its results as parsed JSON, as soon as JSON structures are complete.
    # @param (see #streamed_api_command)
    # Only works if a block is given.
    # @return [nil]
    def json_streamed_api_command(command, stdin = nil, *args, &block)
      partial_out = ''
      streamed_api_command(command, stdin, *args) do |line|
        partial_out << line
        begin
          parsed_json = JSON.parse(partial_out, symbolize_names: true, object_class: ActiveSupport::HashWithIndifferentAccess)
          partial_out = ''
          yield parsed_json
        rescue
        end
      end
    end

    # Utility method to generate args lists to be passed to `api_command` and the like
    # @param [Array <Array(String, Object)>]
    # @return [Array <String>]
    # The array is expected to contain Arrays as elements. Each of them is passed to #generate_args.
    # Returns a flattened array with the resulting arguments.
    # @example
    #   generate_args_list([['-l', 3], ['-i'], ['-t', nil], ['My text']]) #=> ['-l', 3, '-i', 'My text']
    def generate_args_list(args_list)
      args = args_list.map { |args| generate_args(args) }.flatten.compact
    end

    # Utility method to generate the arguments for a single command option
    # @param args [Array]
    # @return [Array, nil]
    # If the last argument is blank, the whole list is ignored and returns nil
    # @example Single element
    #   generate_args(['-h']) #=> ['-h']
    # @example Two non-nil elements
    #   generate_args(['-t', "My title"]) #=> ['-t', "My title"]
    # @example Two elements, with the last being nil
    #   generate_args(['-t', nil]) #=> nil
    def generate_args(args)
      args.empty? || args.last.blank? ? nil : args
    end

    protected

    def prepare_command_args(command, args)
      command = "termux-" + Shellwords.escape(command.to_s)
      args = args.map { |arg| arg.to_s }
      return command, args
    end
  end
end
