require_relative 'HTMLTag.rb'

class HTMLTagVoid < HTMLTag
    @@void_tag_types_list = ['area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'menuitem', 'meta', 'param', 'source', 'track', 'wbr', 'path']
    @@void_tag_no_params = ['br', 'hr']

    def initialize(html_line, str)
        super(html_line, str)

        #puts "Void tag created: #{str}"
    end

    def HTMLTagVoid::is_type_void(str)
        begin
            type_str =  str.match(/<\s*\/?\s*(\w+)\s*.*>/).captures[0]
            @@void_tag_types_list.include?(type_str) ? (return true) : (return false)
        rescue
            return false
        end
    end

    def HTMLTagVoid::is_valid_void_tag(str)
        if self.is_type_void(str)
            if str.match(/br|hr/)
                return true;
            else #void tag requires attributes
                if str.match(/[\w\-_]+=.*/)
                    return true;
                else
                    return false;
                end
            end
        else
            return false
        end
    end

end