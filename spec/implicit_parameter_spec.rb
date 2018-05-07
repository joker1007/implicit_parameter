RSpec.describe ImplicitParameter do
  class Foo
    extend ImplicitParameter::Caller

    attr_accessor :foo
    implicit :@foo

    def initialize
      @foo = 1
    end

    def call_bar
      Bar.new.bar(:from_foo)
    end

    def call_baz
      Baz.new.bar(:from_foo)
    end
  end

  class Bar
    extend ImplicitParameter::Callee

    def bar(foo, arg)
      [foo, arg]
    end
    implicit_paramter :bar, Integer
  end

  class Baz < Bar
  end

  it "inject parameter implicitly" do
    expect(Foo.new.call_bar).to eq([1, :from_foo])
    expect(Foo.new.call_baz).to eq([1, :from_foo])
    expect(Foo.new.tap { |f| f.foo = :sym }.call_bar).to eq([nil, :from_foo])
    expect(Foo.new.tap { |f| f.foo = 2 }.call_bar).to eq([2, :from_foo])
    expect(Bar.new.bar(:from_it)).to eq([nil, :from_it])
  end
end
