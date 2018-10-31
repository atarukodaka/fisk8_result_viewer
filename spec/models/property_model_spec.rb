require 'rails_helper'

RSpec.describe Property do
  class Foo
    extend Property
    property :bar, 'default value'
    property(:aaa) { 'AAA' }
    properties :baz, :hoge
  end

  let(:foo) { Foo.new }
  it {
    expect(foo.bar).to eq('default value')
    expect(foo.aaa).to eq('AAA')
    expect(foo.bar(3).class).to eq(Foo)
    expect(foo.bar).to eq(3)
    foo.baz(:BAZ).hoge(:HOGE)
    expect(foo.baz).to eq(:BAZ)
    expect(foo.hoge).to eq(:HOGE)
  }
  it 'setter' do
    ## setter
    foo.bar = :bar
    expect(foo.bar).to eq(:bar)
  end
  it 'updater' do
    ## update hash
    foo.bar = { foo: :AAA }
    foo.update_bar(foo: :BBB, bar: :ZZZ)
    expect(foo.bar[:foo]).to eq(:BBB)
    expect(foo.bar[:bar]).to eq(:ZZZ)
  end
end
