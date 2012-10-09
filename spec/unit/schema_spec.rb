require_relative '../helper'

describe Gangsta::Schema do
  it 'should require a name' do
    lambda{Gangsta::Schema.new()}.should raise_error
    lambda{Gangsta::Schema.new(name: :test)}.should_not raise_error
  end

  it 'should always return a symbol for the name' do
    Gangsta::Schema.new(name: 'test').name.should == :test
  end

  it 'should have no parent and be a leaf by default' do
    Gangsta::Schema.new(name: 'test').parent.should == nil
    Gangsta::Schema.new(name: 'test').leaf?.should be_true
  end

  it 'can add children' do
    root = Gangsta::Schema.new(name: 'test')
    root.add_definable(name: 'testchild')
    root.children.first.name.should == :testchild
    root.leaf?.should be_false
    root.children.first.leaf?.should be_true
  end

  it 'has a definer' do
    Gangsta::Definer.should === Gangsta::Schema.new(name: :test).definer
  end

  it 'defaults getter and setter to match name' do
    t = Gangsta::Schema.new(name: :test)
    t.getter.should == :test
    t.setter.should == :test=
  end

  it 'should allow override of getter and setter' do
    t = Gangsta::Schema.new(name: :test, getter: :get_test, setter: :set_test)
    t.getter.should == :get_test
    t.setter.should == :set_test
  end

  

  context 'tree structure' do
    let (:root) { 
      root = Gangsta::Schema.new(name: 'test')
      root.add_definable(name: 'testchild')
      root.children.first.add_definable(name: 'grandchild')
      root
    }
    let (:child) { root.children.first }
    let (:grandchild) { child.children.first }

    it 'can access multiple levels' do
      grandchild.name.should == :grandchild
    end

    it 'any node should know its root' do
      grandchild.root.should == root
    end

    context 'binding' do
      before(:all) do
        Test = Struct.new(:test)
      end
      let (:obj) {
        Test.new.tap do |t|
          t.test = "hello"
        end
      }

      let (:child_obj) {
        Test.new.tap do |t|
          t.test = "world"
        end
      }

      let (:bound) { root.bound_to(obj) }
      let (:bchild) { bound.children.first }
      let (:bgrandchild) { bchild.children.first }

      it 'should bind the whole tree to an object' do
        bchild.bound?.should be_true
        bgrandchild.bound?.should be_true
        bgrandchild.bound_object.should == obj
      end

      it 'should allow another bound object to a child and keep things straight' do
        bchild.bind_object(child_obj)
        bchild.bound_object.should == child_obj
        bgrandchild.bound_object.should == child_obj
        bound.bound_object.should == obj
      end
    end

  end

end
