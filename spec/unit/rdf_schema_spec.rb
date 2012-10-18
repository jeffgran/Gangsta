require_relative '../helper'

describe Gangsta::Schema do
  let(:ns) { { dc: 'http://purl.org/dc/terms/', foaf: 'http://xmlns.com/foaf/0.1/' } }

  it 'should allow assigning namespaces' do
    lambda{
      Gangsta::Schema.new(name: :test, namespaces: ns)
    }.should_not raise_error
  end

  it 'should not allow borked namespaces' do
    lambda{
      Gangsta::Schema.new(name: :test, namespaces: 'http://purl.org/dc/terms/')
    }.should raise_error
  end

  it 'should know its namespaces' do
    gs = Gangsta::Schema.new(name: :test, namespaces: ns)
    gs.namespaces.should == ns
  end

  it 'can access a namespace by prefix' do
    gs = Gangsta::Schema.new(name: :test, namespaces: ns)
    gs.namespaces[:dc].should == 'http://purl.org/dc/terms/'
  end

  context 'schema tree' do
    let (:root) { 
      root = Gangsta::Schema.new(name: 'test', namespaces: ns, namespace: :dc)
      root.add_child_schema(name: 'testchild')
      root.children.first.add_child_schema(name: 'grandchild')
      root
    }
    let (:child) { root.children.first }
    let (:grandchild) { child.children.first }

    it 'child can access namespace directly, pulling from parent' do
      child.namespaces[:dc].should == 'http://purl.org/dc/terms/'
      grandchild.namespaces[:dc].should == 'http://purl.org/dc/terms/'
    end

    it 'each child should know its namespace' do
      child.namespace.should == :dc
      grandchild.namespace.should == :dc
    end

    it 'can make a qname if it has a namespace' do
      root.qname.should == 'dc:test'
      child.qname.should == 'dc:testchild'
      grandchild.qname.should == 'dc:grandchild'
    end
  end

  context 'schema tree with different namespaces' do
    
    let (:root) { 
      root = Gangsta::Schema.new(name: 'test', namespaces: ns, namespace: :dc)
      root.add_child_schema(name: 'testchild', namespace: :foaf)
      root.children.first.add_child_schema(name: 'grandchild')
      root
    }
    let (:child) { root.children.first }
    let (:grandchild) { child.children.first }

    it 'root namespace should stay the same' do
      root.namespace.should == :dc
    end

    it 'child schema can have a different namespace' do
      child.namespace.should == :foaf
    end

    it 'grandchild defaults to childs namespace if present' do
      grandchild.namespace.should == :foaf
    end

    it 'can make a qname if it has a namespace' do
      root.qname.should == 'dc:test'
      child.qname.should == 'foaf:testchild'
      grandchild.qname.should == 'foaf:grandchild'
    end
  end

end
