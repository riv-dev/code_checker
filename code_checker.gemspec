Gem::Specification.new do |s|
    s.name = 'code_checker'
    s.version = '2.0.9'
    s.date = '2017-09-14'
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
                "lib/models/SASSDirective.rb",
                "lib/models/SASSKeyFrames.rb",
                "lib/models/RyukyuHTMLValidator.rb",
                "lib/models/RyukyuSASSValidator.rb",
                "lib/models/RyukyuCrossValidator.rb",
                "lib/models/ACheckerValidator.rb",
                "lib/models/ValidationMessage.rb",
                "lib/views/ValidationConsoleView.rb",
                "lib/views/JSONView.rb",
                "lib/adapters/ValidationExportAdapter.rb"]
    s.add_dependency "colorize"
    s.add_dependency "nokogiri"
    s.add_dependency "w3c_validators"
    s.executables = ["code_checker"]
    s.homepage = 'https://github.com/riv-dev/welcome'
    s.license = 'MIT'
end