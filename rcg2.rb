require "yaml"
require "json"

class Generator
    def initialize(filename, destination)
        config = YAML.load_file(filename)
        Dir.chdir(destination)

        @imports = config["imports"]
        @type = config["type"]
        if @type == "class"
            @state = config["state"]
            @functions = config["functions"]
        end

        @name = config["name"]
        @targetFile = "#{@name}.js"
        @description = config["description"]

        @props = config["props"]

        @docPrefixes = { startDoc: "/**", startLine: "\n * ", endDoc: "\n */\n" }
        @t = " " * 4
    end

    def isClass?
        @type == "class"
    end

    def writeFile(content, mode)
        file = File.new(@targetFile, mode)
        file.write(content)
        file.close
    end

    def iterateStruct(struct, callback, tabs)
        struct.each do |k, v|
            callback.(k, v, tabs)
        end
    end

    def generateDependencies
        docStart = [
            @docPrefixes[:startDoc],
            @docPrefixes[:startLine],
            "@module #{@name}",
            @docPrefixes[:startLine]
        ]

        dependencies = []

        @imports.each do |k, v|
            importStatement = "import "

            if v.is_a? Array
                importStatement += "{ "
                v.each { |dep| importStatement+= "#{dep}, " }
                importStatement.gsub!(/, $/, " ")
                importStatement += "} "
            else
                importStatement += "#{v} "
            end

            importStatement += "from '#{k}';\n"
            dependencies << importStatement

            docStart << @docPrefixes[:startLine]
            docStart << "@requires #{k.split("/").last}"
        end

        docStart << @docPrefixes[:endDoc]
        startString = "#{docStart.join("")}\n#{dependencies.join("")}\n"

        self.writeFile(startString, "w")
    end

    def openClass
        docStart = [
            @docPrefixes[:startDoc],
            @docPrefixes[:startLine],
            "@class #{@name}",
            @docPrefixes[:endDoc]
        ].join("")

        classStart = "class #{@name} extends React.Component {\n"
        constructor = [
            "#{@t}constructor(props) {\n",
            "#{@t * 2}super(props);\n\n",
            "#{@t * 2}this.state = {\n"
        ]

        initState = -> (k, v, tabs) {
            if v.is_a? Hash
                constructor << "#{@t * tabs}#{k}: {\n"
                self.iterateStruct(v, initState, tabs + 1)
                constructor.last.gsub!(/,$/, "")
                constructor << "#{@t * tabs}},\n"
            elsif v == ""
                constructor << "#{@t * tabs}#{k}: '#{v}',\n"
            else
                constructor << "#{@t * tabs}#{k}: #{v},\n"
            end
        }
        self.iterateStruct(@state, initState, 3)
        constructor.last.gsub!(/,$/, "")

        constructor << "#{@t * 2}}\n"
        constructor << "#{@t}}\n\n"

        openString = "#{docStart}#{classStart}#{constructor.join("")}"

        self.writeFile(openString, "a")
    end

    def openFunction
        docStart = [
            @docPrefixes[:startDoc],
            @docPrefixes[:startLine],
            "#{@name}: #{@description}",
            @docPrefixes[:startLine],
            @docPrefixes[:startLine],
            "@function",
        ]

        funcStart = "const #{@name} = ({ "

        initParams = -> (k, v, tabs) {
            funcStart += "#{k}, "
            req = v["required"] ? "(required)" : "(optional)"
            docStart << "#{@docPrefixes[:startLine]}@param {#{v["type"]}} #{k} #{req} #{v["description"]}"
        }
        self.iterateStruct(@props, initParams, 0)

        funcStart.gsub!(/, $/, " ")
        funcStart += "}) => {\n"
        docStart << @docPrefixes[:endDoc]

        openString = "#{docStart.join("")}#{funcStart}"

        self.writeFile(openString, "a")
    end

    def generateInit
        @type == "class" ? self.openClass : self.openFunction
    end

    def generateFunctions
        funcString = []
        @functions.each { |fn| funcString << "#{@t}#{fn} = () => {}\n\n" }

        self.writeFile(funcString.join(""), "a")
    end

    def generateReturn
        returnString = []

        if self.isClass?
            returnString << "#{@t}render() {\n"
            returnString << @t
        end

        returnString << "#{@t}return ();\n"
        returnString << "#{@t}}\n" if self.isClass?
            
        self.writeFile(returnString.join(""), "a")
    end
    
    def closeOut
        closeString = "}\n\n"
        self.writeFile(closeString, "a")
    end

    def generateDefaults
        defaultString = [ "#{@name}.defaultProps = {\n" ]

        defaultGen = -> (k, v, tabs) {
            if !v["default"].nil?
                if v["default"] == ""
                    defaultString << "#{@t * tabs}#{k}: '',\n"
                elsif v["default"].is_a?(String) && v["default"] != "null"
                    defaultString << "#{@t * tabs}#{k}: '#{v["default"]}',\n"
                else
                    defaultString << "#{@t * tabs}#{k}: #{v["default"]},\n"
                end
            end
        }
        self.iterateStruct(@props, defaultGen, 1)
        defaultString.last.gsub!(/,$/, "")
        
        defaultString << "}\n\n"

        self.writeFile(defaultString.join(""), "a")
    end

    def generateProptypes
        proptypesString = [ "#{@name}.propTypes = {\n" ]

        propGen = -> (k, v, tabs) {
            proptypesString << "#{@t * tabs}#{k}: "
            proptypesString << "PropTypes.arrayOf(" if v["array"]
            proptypesString << "PropTypes.#{v["type"]}"
            isRequired = v["required"] ? ".isRequired" : ""

            if !v["children"].nil?
                proptypesString << "({\n"
                self.iterateStruct(v["children"], propGen, tabs + 1)
                proptypesString.last.gsub!(/,$/, "")
                proptypesString << "#{@t * tabs}})"
                proptypesString << ")" if v["array"]
                proptypesString << "#{isRequired},\n"
            else
                proptypesString << "#{isRequired},\n"
            end
        }
        self.iterateStruct(@props, propGen, 1)
        proptypesString.last.gsub!(/,$/, "")

        proptypesString << "}\n\n"

        self.writeFile(proptypesString.join(""), "a")
    end

    def generateExport
        self.writeFile("export default #{@name};", "a")
    end
end

path = File.realpath(ARGV[0]).split("/")
dest = File.realpath(ARGV[1])

file = path.pop

Dir.chdir(path.join("/"))

gen = Generator.new(file, dest)
gen.generateDependencies
gen.generateInit
gen.generateFunctions if gen.isClass?
gen.generateReturn
gen.closeOut
gen.generateDefaults
gen.generateProptypes
gen.generateExport