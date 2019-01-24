class Context
  attr_reader :context_name, :examples

  def initialize(context_name, &block)
    @context_name = context_name
    @contexts = []
    @examples = []
    instance_eval &block
  end

  def context(context_name, &block)
    @contexts << Context.new(context_name, &block)
  end

  def step(context_name, &block)
    @examples << Example.new(context_name, &block)
  end

  def render_results
    MyLogger.log context_name
    @contexts.each do |describe_node|
      MyLogger.log '  ' + describe_node.context_name
      describe_node.examples.each do |example_node|
        # mark examples without expectations as 'passed'
        result = example_node.test_result == false ? 'failed' : 'passed'
        MyLogger.log '    ' + example_node.context_name + ': ' + result
      end
    end
  end

  private

  attr_accessor :contexts
end

def context(context_name, &block)
  Context.new(context_name, &block)
end
