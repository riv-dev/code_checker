class HTMLTagVoid < HTMLTag
    def initialize(html_line, str)
        super(html_line, str)

        puts "Void tag created: #{str}"
    end
end