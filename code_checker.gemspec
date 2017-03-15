Gem::Specification.new do |s|
    s.name = 'code_checker'
    s.version = '1.4.2'
    s.date = '2017-03-02'
    s.summary = "Check HTML & SASS code for basic syntax and coding rules"
    s.authors = ["Ken Le"]
    s.email = "kenle545@gmail.com"
    s.files = ["lib/code_checker.rb",
                "lib/models/CodeFile.rb",
                "lib/models/CodeLine.rb",
                "lib/models/HTMLFile.rb",
                "lib/models/HTMLLine.rb",
                "lib/models/HTMLElement.rb",
                "lib/models/HTMLContent.rb",
                "lib/models/HTMLTag.rb",
                "lib/models/HTMLTagClose.rb",
                "lib/models/HTMLTagFactory.rb",
                "lib/models/HTMLTagOpen.rb",
                "lib/models/HTMLTagVoid.rb",
                "lib/models/HTMLFileFactory.rb",
                "lib/models/HTMLFileHBS.rb",
                "lib/models/HTMLFilePHP.rb",
                "lib/models/HTMLFileEJS.rb",
                "lib/models/SASSFile.rb",
                "lib/models/SASSLine.rb",
                "lib/models/SASSProperty.rb",
                "lib/models/SASSSelector.rb",
                "lib/models/SASSMixin.rb",
                "lib/models/SASSInclude.rb",
                "lib/views/ErrorView.rb"]
    s.add_dependency "colorize"
    s.add_dependency "nokogiri"
    s.executables = ["code_checker"]
    s.homepage = 'https://github.com/riv-dev/welcome'
    s.license = 'MIT'
end