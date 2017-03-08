require_relative 'HTMLFileHBS.rb'
require_relative 'HTMLFilePHP.rb'
require_relative 'HTMLFileEJS.rb'

class HTMLFileFactory
    
    def self.create(file_path, file_type)
        if file_type.match(/^\.?html$/i)
            return HTMLFile.new(file_path)
        elsif file_type.match(/^\.?hbs$/i)
            return HTMLFileHBS.new(file_path)
        elsif file_type.match(/^\.?handlebars$/i)
            return HTMLFileHBS.new(file_path)
        elsif file_type.match(/^\.?php$/i)
            return HTMLFilePHP.new(file_path)
        elsif file_type.match(/^\.?ejs$/i)
            return HTMLFileEJS.new(file_path)
        else
            return nil
        end
    end

    def self.get_supported_types
      return ['html','hbs','handlebars','php','ejs']
    end
end