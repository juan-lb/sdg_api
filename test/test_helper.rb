ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

require 'webmock/minitest'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Verifica que los campos de record coincidan con los de attributes después
  # de ejecutar el bloque
  def assert_record_differences(record, attributes, message = nil, &block)

    attributes.each do |key, value|
      if record.respond_to? key
        now = record.send(key)
        error = "#{key} value is '#{now}' which is the same as the expected new value"
        error = "#{message}\n#{error}" if message
        assert_not_equal value, now, error
      end
    end

    yield

    record.reload

    attributes.each do |key, value|
      if record.respond_to? key
        now = record.send(key)
        error = "#{key} didn't change its value to '#{value}', current value is '#{now}'"
        error = "#{message}\n#{error}" if message
        assert_equal value, now, error
      end
    end
  end

  # Runs assert_difference with a number of conditions and varying difference
  # counts.
  #
  # Call as follows:
  #
  # assert_differences([['Model1.count', 2], ['Model2.count', 3]])
  #
  def assert_differences(expression_array, message = nil, &block)
    b = block.send(:binding)
    before = expression_array.map { |expr| eval(expr[0], b) }

    yield

    expression_array.each_with_index do |pair, i|
      e = pair[0]
      difference = pair[1]
      error = "#{e.inspect} didn't change by #{difference}"
      error = "#{message}\n#{error}" if message
      assert_equal(before[i] + difference, eval(e, b), error)
    end
  end
end
