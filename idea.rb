class Package# < ActiveRecord::Base
  

  # take an optional arg like `gansta :spdx` for more than one represenation schema
  gangsta do

    default_vocab "http://olex.openlogic.com/olex-governance"
    vocab :dc, "http://purl.org/dc/terms/"

    # id is not special -- anything that returns another gangsta (rdf) object is a "link" like this
    id :id

    # optional second arg to specify the universal predicate type?
    name :name, vocab: :dc

    # if lambdas
    description :description, if: lambda{|obj| current_user.allowed_to_see_description?}

    #alternatively, for simple ones as above, an auto feature?
    auto :id, :name, :another_easy_one

    location lambda{ |obj| obj.internalized? ? obj.internal_location : obj.provenance } # bad example... but might need lambdas? or maybe not... just write a method
    

    # maybe?
    versions do
      self.package_versions # just pass it an array of anything?  # just try calling .to_gangsta on each and then to_s?
    end

    # maybe
    # doensn't work as well... either pv turns into a string or... it is a whole graph getting stuffed into the "object".
    versions do
      self.package_versions.each do |pv|
        version pv #again, .to_gangsta || .to_s ?
      end
    end

    # different result, but would be valid:
    versions do
      self.package_versions.each do |pv|
        version 
      end
    end


    links do
      delete lambda { |obj| packages_url(obj) } do
        method 'delete' # allow static literal strings
      end
    end
    
    
  end

end
