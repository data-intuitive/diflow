process process_poc11 {

    input:
        tuple val(id), val(input), val(config)
    output:
        tuple val("${id}"), val(output), val("${config}")
    exec:
        if (config.operator == "+")
           output = input.toInteger() + config.term.toInteger()
        else
           output = input.toInteger() - config.term.toInteger()

}
