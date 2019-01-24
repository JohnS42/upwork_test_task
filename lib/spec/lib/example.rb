class Example
  attr_reader :context_name, :test_result

  def initialize(context_name, &block)
    @context_name = context_name
    instance_eval &block
  end

  def expect(result)
    @result = result
    self
  end

  def to(expectation)
    @test_result = expectation.call(@result)
  end

  def eq(expectation)
    Proc.new { |n| n.eql?(expectation) }
  end

  private
  attr_reader :result
end
