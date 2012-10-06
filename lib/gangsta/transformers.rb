require_relative "./transformer.rb" #base class
Dir.glob(File.dirname(__FILE__) + '/transformers/*') {|f| require f}
