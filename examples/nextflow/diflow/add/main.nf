nextflow.preview.dsl=2
import java.nio.file.Paths
if (!params.containsKey("input") || params.input == "") {
    exit 1, "ERROR: Please provide a --input parameter containing an input file/dir or a wildcard expression"
}
if (!params.containsKey("output") || params.output == "" ) {
    exit 1, "ERROR: Please provide a --output parameter for storing the output"
}

def renderCLI(command, arguments) {

    def argumentsList = arguments.collect{ it ->
        (it.otype == "")
            ? "\'" + it.value + "\'"
            : (it.type == "boolean_true")
                ? it.otype + it.name
                : (it.value == "")
                    ? ""
                    : it.otype + it.name + " \'" + ((it.value in List && it.multiple) ? it.value.join(it.multiple_sep): it.value) + "\'"
    }

    def command_line = command + argumentsList

    return command_line.join(" ")
}

// files is either String, List[String] or HashMap[String,String]
def outFromIn(files) {
    if (files in List || files in HashMap) {
        // We're in join mode, files is List[String]
        return "add" + "." + extension
    } else {
        // files filename is just a String
        def splitString = files.split(/\./)
        def prefix = splitString.head()
        def extension = splitString.last()
        return prefix + "." + "add" + "." + extension
    }
}

// In: Hashmap key -> DataObjects
// Out: Arrays of DataObjects
def overrideInput(params, str) {

    // `str` in fact can be one of:
    // - `String`, 
    // - `List[String]`,
    // - `Map[String, String | List[String]]`
    // Please refer to the docs for more info
    def overrideArgs = params.arguments.collect{ it ->
      (it.value.direction == "Input" && it.value.type == "file")
        ? (str in List || str in HashMap)
            ? (str in List)
                ? it.value + [ "value" : str.join(it.value.multiple_sep)]
                : (str[it.value.name] != null)
                    ? (str[it.value.name] in List)
                        ? it.value + [ "value" : str[it.value.name].join(it.value.multiple_sep)]
                        : it.value + [ "value" : str[it.value.name]]
                    : it.value + [ "value" : "PROBLEMS" ]
            : it.value + [ "value" : str ]
        : it.value
    }

    def newParams = params + [ "arguments" : overrideArgs ]

    return newParams
}

def overrideOutput(params, str) {

    def update = [ "value" : str ]

    def overrideArgs = params.arguments.collect{it ->
      (it.direction == "Output" && it.type == "file")
        ? it + update
        : it
    }

    def newParams = params + [ "arguments" : overrideArgs ]

    return newParams
}


process executor {
  
  tag "${id}"
  echo { (params.debug == true) ? true : false }
  cache 'deep'
  stageInMode "symlink"
  container "${params.dockerPrefix}${container}"
  
  input:
    tuple val(id), path(input), val(output), val(container), val(cli)
  output:
    tuple val("${id}"), path("${output}")
  script:
    """
    # Running the pre-hook when necessary
    echo Nothing before
    # Adding NXF's `$moduleDir` to the path in order to resolve our own wrappers
    export PATH="${moduleDir}:\$PATH"
    # Echo what will be run, handy when looking at the .command.log file
    echo Running: $cli
    # Actually run the command
    $cli
    """

}

workflow add {

    take:
    id_input_params_

    main:

    def key = "add"

    def id_input_output_function_cli_ =
        id_input_params_.map{ id, input, _params ->
            // TODO: make sure input is List[Path], HashMap[String,Path] or Path, otherwise convert
            // NXF knows how to deal with an List[Path], not with HashMap !
            def checkedInput =
                (input in HashMap)
                    ? input.collect{ k, v -> v }.flatten()
                    : input
            // filename is either String, List[String] or HashMap[String, String]
            def filename =
                (input in List || input in HashMap)
                    ? (input in List)
                        ? input.collect{ it.name }
                        : input.collectEntries{ k, v -> [ k, (v in List) ? v.collect{it.name} : v.name ] }
                    : input.name
            def defaultParams = params[key] ? params[key] : [:]
            def overrideParams = _params[key] ? _params[key] : [:]
            def updtParams = defaultParams + overrideParams
            // now, switch to arrays instead of hashes...
            def outputFilename = outFromIn(filename)
            def updtParams1 = overrideInput(updtParams, filename)
            def updtParams2 = overrideOutput(updtParams1, outputFilename)
            new Tuple5(
                id,
                checkedInput,
                outputFilename,
                updtParams2.container,
                renderCLI([updtParams2.command], updtParams2.arguments)
            )
        }
    result_ = executor(id_input_output_function_cli_) \
        | join(id_input_params_) \
        | map{ id, output, input, original_params ->
            new Tuple3(id, output, original_params)
        }

    emit:
    result_

}

workflow {

   def id = params.id
   def inputPath = Paths.get(params.input)
   def ch_ = Channel.from(inputPath).map{ s -> new Tuple3(id, s, params)}

   add(ch_)
}
