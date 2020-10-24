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

process addTupleWithParameter {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output)
    exec:
        output = input + term

}

workflow poc6 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, 10 ]} \
        | addTupleWithParameter \
        | view{ it }

}

process addTupleWithHash {

    input:
        tuple val(id), val(input), val(config)
    output:
        tuple val("${id}"), val(output)
    exec:
        output = (config.operator == "+") ? input + config.term : input - config.term

}

workflow poc7 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, [ "operator" : "-", "term" : 10 ]  ]} \
        | addTupleWithHash \
        | view{ it }

}

process addTupleWithProcessHash {

    input:
        tuple val(id), val(input), val(config)
    output:
        tuple val("${id}"), val(output)
    exec:
        def thisConf = config.addTupleWithProcessHash
        output = (thisConf.operator == "+") ? input + thisConf.term : input - thisConf.term

}

workflow poc8 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, [ "addTupleWithProcessHash" : [ "operator" : "-", "term" : 10 ] ] ] } \
        | addTupleWithProcessHash \
        | view{ it }

}

process addTupleWithProcessHashScript {

    input:
        tuple val(id), val(input), val(config)
    output:
        tuple val("${id}"), stdout
    script:
        def thisConf = config.addTupleWithProcessHashScript
        def operator = thisConf.operator
        def term = thisConf.term
        """
        echo \$( expr $input $operator ${thisConf.term} )
        """

}

workflow poc9 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, [ "addTupleWithProcessHashScript" : [ "operator" : "-", "term" : 10 ] ] ] } \
        | addTupleWithProcessHashScript \
        | view{ it }

}

process process_poc10a {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input.toInteger() + term.toInteger()

}

process process_poc10b {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input.toInteger() - term.toInteger()

}

workflow poc10 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, 10 ] } \
        | process_poc10a \
        | map{ id, value, term -> [ id, value, 5 ] } \
        | map{ [ it[0], it[1], 5 ] } \
        | map{ x -> [ x[0], x[1], 5 ] } \
        | process_poc10b \
        | view{ it }

}

include process_poc11 as process_poc11a from './examples/poc/poc11.nf'
include process_poc11 as process_poc11b from './examples/poc/poc11.nf'

workflow poc11 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, [ : ] ] } \
        | map{ id, value, config -> [ id, value, [ "term" : 5, "operator" : "+" ] ] } \
        | process_poc11a \
        | map{ id, value, config -> [ id, value, [ "term" : 11, "operator" : "-" ] ] } \
        | process_poc11b \
        | view{ [ it[0], it[1] ] }

}

process process_poc12 {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input.sum()

}

workflow poc12 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, 10 ] } \
        | process_poc10a \
        | toList \
        | map{ [ "sum", it.collect{ id, value, config -> value }, [ : ] ] } \
        | process_poc12 \
        | view{ [ it[0], it[1] ] }

}

process process_poc13 {

    input:
        tuple val(id), file(input), val(config)
    output:
        tuple val("${id}"), file("output.txt"), val("${config}")
    script:
        """
        a=`cat $input`
        let result="\$a + ${config.term}"
        echo "\$result" > output.txt
        """

}

workflow poc13 {

    Channel.fromPath( params.input ) \
        | map{ el -> [ el.baseName.toString(), el, [ "operator" : "-", "term" : 10 ]  ]} \
        | process_poc13 \
        | view{ [ it[0], it[1] ] }

}

process process_poc14 {

    publishDir "output/"

    input:
        tuple val(id), file(input), val(config)
    output:
        tuple val("${id}"), file("output.txt"), val("${config}")
    script:
        """
        a=`cat $input`
        let result="\$a + ${config.term}"
        echo "\$result" > output.txt
        """

}

workflow poc14 {

    Channel.fromPath( params.input ) \
        | map{ el -> [ el.baseName.toString(), el, [ "operator" : "-", "term" : 10 ]  ]} \
        | process_poc14 \
        | view{ [ it[0], it[1] ] }

}

process process_poc15 {

    publishDir "output/${config.id}"

    input:
        tuple val(id), file(input), val(config)
    output:
        tuple val("${id}"), file("output.txt"), val("${config}")
    script:
        """
        a=`cat $input`
        let result="\$a + ${config.term}"
        echo "\$result" > output.txt
        """

}

workflow poc15 {

    Channel.fromPath( params.input ) \
        | map{ el -> [ el.baseName.tostring(), el, [ "id": el.baseName, "operator" : "-", "term" : 10 ]  ]} \
        | process_poc15 \
        | view{ [ it[0], it[1] ] }

}

process process_poc16 {

    publishDir "output/${config.id}"

    input:
        tuple val(id), file(input), val(config)
    output:
        tuple val("${id}"), file(params.output), val("${config}")
    script:
        """
        a=`cat $input`
        let result="\$a + ${config.term}"
        echo "\$result" > ${params.output}
        """

}

workflow poc16 {

    Channel.fromPath( params.input ) \
        | map{ el -> [ el.baseName.toString(), el, [ "id": el.baseName, "operator" : "-", "term" : 10 ]  ]} \
        | process_poc16 \
        | view{ [ it[0], it[1] ] }

}

process process_poc17 {

    publishDir "output"

    input:
        tuple val(id), file(input), val(config)
    output:
        tuple val("${id}"), file("${config.output}"), val("${config}")
    script:
        """
        a=`cat $input`
        let result="\$a + ${config.term}"
        echo "\$result" > ${config.output}
        """

}

workflow poc17 {

    Channel.fromPath( params.input ) \
        | map{ el -> [
            el.baseName.toString(),
            el,
            [
                "output" : "output_from_${el.baseName}.txt",
                "id": el.baseName,
                "operator" : "-",
                "term" : 10
            ]
          ]} \
        | process_poc17 \
        | view{ [ it[0], it[1] ] }

}

def out_from_in = { it -> it.baseName + "-out.txt" }

process process_poc18 {

    publishDir "output"

    input:
        tuple val(id), file(input), val(config)
    output:
        tuple val("${id}"), file("${out}"), val("${config}")
    script:
        out = out_from_in(input)
        """
        a=`cat $input`
        let result="\$a + ${config.term}"
        echo "\$result" > ${out}
        """

}

workflow poc18 {

    Channel.fromPath( params.input ) \
        | map{ el -> [
            el.baseName.toString(),
            el,
            [
                "id": el.baseName,
                "operator" : "-",
                "term" : 10
            ]
          ]} \
        | process_poc18 \
        | view{ [ it[0], it[1] ] }

}

process process_poc19 {

    input:
        tuple val(id), file(input), val(config)
    output:
        tuple val("${id}"), file("output.yaml"), val("${config}")
    script:
        """
        yq r ${input} f > output.yaml
        """

}

workflow poc19 {

    Channel.fromPath( "/Users/toni/code/diflow/data/input.yaml" ) \
        | map{ el -> [ "id", el, [ : ] ]} \
        | process_poc19 \
        | view{ [ it[0], it[1].text.trim() ] }

}

process process_poc20 {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input[0] / input[1]

}

workflow poc20 {

    Channel.from( [ 1, 2 ] ) \
        | map{ el -> [ el.toString(), el, 10 ] } \
        | process_poc10a \
        | toSortedList{ a,b -> a[0] <=> b[0] } \
        | map{ [ "sum", it.collect{ id, value, config -> value }, [ : ] ] } \
        | process_poc20 \
        | view{ [ it[0], it[1] ] }

}


// -----------

workflow runOrSkip {
    take:
    data_          // Data Channel
    thisProcess    // The map, process or workflow to run
    runOrNot       // Function/closure to check if step needs to run, returns Boolean
    thisStep       // The current step to run or not

    main:

    runStep_ = data_.branch{ it ->
            run: runOrNot(thisStep)
            skip: ! runOrNot(thisStep)
        }

    step_ = runStep_.run \
        | thisProcess \
        | mix(runStep_.skip) \

    emit:
    step_
}

def runOrNot(thisStep) {

    def STEPS = [ "step1", "step2", "step3", "step4", "step5" ]

    def steps = params.steps.split(",")
                    .collect{ it ->
                        (it.contains("-"))
                            ? STEPS[STEPS.indexOf(it.split("-")[0])..STEPS.indexOf(it.split("-")[1])]
                            : it
                    }.flatten()

    return steps.contains(thisStep)
}

workflow pocA2 {

    input_ = Channel.from( [ 1, 2, 3 ] )

    step1_ = runOrSkip(input_, map{ it -> it * 2 }, runOrNot, "step1")
    step2_ = runOrSkip(step1_, map{ it -> it + 5 }, runOrNot, "step2")
    step3_ = runOrSkip(step2_, map{ it -> it / 2 }, runOrNot, "step3")
    step4_ = runOrSkip(step3_, map{ it -> it + 1 }, runOrNot, "step4")
    step5_ = runOrSkip(step4_, map{ it -> it + 5 }, runOrNot, "step5")

    step5_.view{ it }

}


// ----------

process process_pocxx {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input.toInteger() + term.toInteger()

}

workflow workflow_pocxx {

    take: input_

    main:
        output_ = process_pocxx(input_)

    emit:
        output_
}

workflow pocxx {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, 10 ] } \
        | workflow_pocxx \
        | workflow_pocxx \
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
