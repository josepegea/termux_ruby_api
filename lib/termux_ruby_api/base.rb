require 'json'
require 'date'
require 'time'
require_relative 'sub_systems'
require 'shellwords'
require 'open3'

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
      command = "termux-" + Shellwords.escape(command.to_s)
      args = args.map { |arg| Shellwords.escape(arg.to_s) }
      stdout, stderr, status = Open3.capture3(command, *args, stdin_data: stdin.to_s)
      raise CommandError.new(status: status, stderr: stderr) unless status.success?
      stdout
    end

    def json_api_command(command, stdin = nil, *args)
      res = api_command(command, stdin, *args)
      return res if res.nil? || res == ''
      JSON.parse(res, symbolize_names: true)
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
  end
end
