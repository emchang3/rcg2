require "yaml"

def writeFile(targetFile, content, mode)
    file = File.new(targetFile, mode)
    file.write(content)
    file.close
end

def iterateStruct(struct, callback)
    struct.each { |k, v| callback.(k, v) }
end

path = File.realpath(ARGV[0]).split("/")
dest = File.realpath(ARGV[1])
file = path.pop
Dir.chdir(path.join("/"))

config = YAML.load_file(file)

Dir.chdir(dest)

targetFile = "#{config["name"]}.csv"

firstLine = "PROPS\n\nNAME, REQUIRED, TYPE, DEFAULT, DESCRIPTION\n"

writeFile(targetFile, firstLine, "w")

props = config["props"]
propsCB = -> (k, v) {
    line = "#{k}, #{v["required"]}, #{v["type"]}, #{v["default"]}, #{v["description"]}\n"
    writeFile(targetFile, line, "a")
}
iterateStruct(props, propsCB)