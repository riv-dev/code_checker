class HTMLTagVoid < HTMLTag
    @@void_tag_types_list = ['area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'menuitem', 'meta', 'param', 'source', 'track', 'wbr']

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
end