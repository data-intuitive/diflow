nextflow.preview.dsl=2

workflow poc1 {

    Channel.from(1) \
        | map{ it + 1 } \
        | view{ it }

}

workflow poc2 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ it + 1 } \
        | view{ it }

}

process add {

    input:
        val(input)
    output:
        val(output)
    exec:
        output = input + 1

}

workflow poc3 {

    Channel.from( [ 1, 2, 3 ] ) \
        | add \
        | view{ it }

}

def waitAndReturn(it) { sleep(2000); return it }

workflow poc4 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ (it == 2) ? waitAndReturn(it) : it } \
        | map{ it + 1 } \
        | view{ it }

}

process addTuple {

    input:
        tuple val(id), val(input)
    output:
        tuple val("${id}"), val(output)
    exec:
        output = input + 1

}

workflow poc5 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el ]} \
        | addTuple \
        | view{ it }

}



workflow pocM {

    Channel.from( params.input ) \
        | add \
        | view{ it }

}

workflow pocN {

    Channel.from(params.input) \
        | map{ it.split(",") } \
        | flatten \
        | map{ it.toInteger() } \
        | map{ i -> [ "", i, params ] } \
        | map{ [ it[0], it[1] + 1, it[2] ] } \
        | view{ it[1] }

}
