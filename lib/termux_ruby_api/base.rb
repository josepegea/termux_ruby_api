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
    def api_command(command, stdin = nil, *args)
      command, args = prepare_command_args(command, args)
      stdout, stderr, status = Open3.capture3(command, *args, stdin_data: stdin.to_s)
      raise CommandError.new(status: status, stderr: stderr) unless status.success?
      stdout
    end

    def json_api_command(command, stdin = nil, *args)
      res = api_command(command, stdin, *args)
      return res if res.nil? || res == ''
      JSON.parse(res, symbolize_names: true, object_class: ActiveSupport::HashWithIndifferentAccess)
    end

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

    def generate_args_list(args_list)
      args = args_list.map { |args| generate_args(args) }.flatten.compact
    end

    def generate_args(args)
      args.empty? || args.last.blank? ? nil : args
    end

    # SubSystems

    def clipboard
      @clipboard ||= TermuxRubyApi::SubSystems::Clipboard.new(self)
    end

    def tts
      @tts ||= SubSystems::Tts.new(self)
    end

    def call_log
      @call_log ||= TermuxRubyApi::SubSystems::CallLog.new(self)
    end

    def location
      @location ||= SubSystems::Location.new(self)
    end

    def sms
      @sms ||= SubSystems::Sms.new(self)
    end

    def sensor
      @sensor ||= SubSystems::Sensor.new(self)
    end

    def dialog
      @dialog ||= SubSystems::Dialog.new(self)
    end

    protected

    def prepare_command_args(command, args)
      command = "termux-" + Shellwords.escape(command.to_s)
      args = args.map { |arg| arg.to_s }
      return command, args
    end
  end
end
