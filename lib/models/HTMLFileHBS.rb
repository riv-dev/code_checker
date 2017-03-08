class HTMLFileHBS < HTMLFile

    #Override
    def process_line_through_templating_engine(str)
        #remove handlebars expressions
        str.gsub!(/\{\{>\s*(\w+.*)\s*\}\}/, '{{ \1 }}')
        return str
    end

end