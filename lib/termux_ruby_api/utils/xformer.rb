module TermuxRubyApi
  module Utils
    class Xformer
      def self.xform(object, args)
        collection = object.is_a?(Array) ? object : [object]
        collection.each { |i| xform_item(i, args) }
        object
      end

      private

      def self.xform_item(item, args)
        return unless item.is_a?(Hash)
        args.each do |arg, type|
          next unless item.key?(arg)
          item[arg] = xform_prop(item[arg], type)
        end
      end

      def self.xform_prop(value, type)
        case type
        when :date
          Date.parse(value)
        when :time
          Time.parse(fix_time(value))
        when :duration
          to_duration(value)
        when :integer
          value.to_i
        when :float
          value.to_f
        when :symbol
          value.to_sym
        else
          value
        end
      end

      def self.to_duration(value)
        parts = value.split(':')
        res = parts.pop.to_i
        res += (parts.pop.to_i * 60) if parts.any?
        res += (parts.pop.to_i * 60 * 60) if parts.any?
        res
      end

      def self.fix_time(time_str)
        # Termux likes to give hours in 24:xx:xx or 24:xx format instead of 00:xx:xx or 00:xx
        time_str.gsub(/\ (24)(:\d\d)/, ' 00' + '\2')
      end
    end
  end
end
