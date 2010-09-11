module CustomMatchers
  
  class Param
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      # Satisfy expectation here. Return false or raise an error if it's not met.
      @actual.include?(@expected)
    end

    def failure_message_for_should
      "expected #{@actual.inspect} to have param #{@expected.inspect}, but it didn't"
    end

    def failure_message_for_should_not
      "expected #{@actual.inspect} not to have param #{@expected.inspect}, but it did"
    end
  end

  def have_param(expected)
    Param.new(expected)
  end
  
end