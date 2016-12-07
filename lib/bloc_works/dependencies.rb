class Object
  # This method is invoked if const_get is passed an undefined constant(symbol),
  # first, converts const to a String,
  # second, runs it through snake_case,
  # third, tries again. 
  def self.const_missing(const)
    require BlocWorks.snake_case(const.to_s)
    Object.const_get(const)
    # const_get returns a constant given a symbol.
    # const_get() is an Object's method.
      # module Foo
      #   class Bar
      #     VAL = 10
      #   end
      #
      #   class Baz < Bar; end
      # end
      #
      # Object.const_get('Foo::Baz::VAL')         # => 10
  end
end
