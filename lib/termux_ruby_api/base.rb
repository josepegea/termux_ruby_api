require 'json'
require 'date'
require 'time'
require_relative 'sub_systems'
require 'shellwords'

module TermuxRubyApi
  class Base
    def api_command(command, *args)
      args = args.map { |arg| Shellwords.escape(arg) }
      res = %x(termux-#{([command] + args).join(' ')})
      raise $? if $?.exitstatus != 0
      res
    end

    def json_api_command(command, *args)
      res = api_command(command, *args)
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
