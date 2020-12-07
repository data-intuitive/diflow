nextflow.preview.dsl=2

// step 1
workflow step1 {
    Channel.from(1) \
        | map{ it + 1 } \
        | view{ it }
}

// step 2
workflow step2 {
    Channel.from( [ 1, 2, 3 ] ) \
        | map{ it + 1 } \
        | view{ it }
}

// step 3
process add {
    input:
        val(input)
    output:
        val(output)
    exec:
        output = input + 1
}

workflow step3 {
    Channel.from( [ 1, 2, 3 ] ) \
        | add \
        | view{ it }
}

// step 4
def waitAndReturn(it) { sleep(2000); return it }

workflow step4 {
    Channel.from( [ 1, 2, 3 ] ) \
        | map{ (it == 2) ? waitAndReturn(it) : it } \
        | map{ it + 1 } \
        | view{ it }
}

// step 5
process addTuple {
    input:
        tuple val(id), val(input)
    output:
        tuple val("${id}"), val(output)
    exec:
        output = input + 1
}

workflow step5 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el ]} \
        | addTuple \
        | view{ it }

}

// step 6
process addTupleWithParameter {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output)
    exec:
        output = input + term

}

workflow step6 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, 10 ]} \
        | addTupleWithParameter \
        | view{ it }

}

// step 7
process addTupleWithHash {

    input:
        tuple val(id), val(input), val(config)
    output:
        tuple val("${id}"), val(output)
    exec:
        output = (config.operator == "+") ? input + config.term : input - config.term

}

workflow step7 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, [ "operator" : "-", "term" : 10 ]  ]} \
        | addTupleWithHash \
        | view{ it }

}

// step 8
process addTupleWithProcessHash {

    input:
        tuple val(id), val(input), val(config)
    output:
        tuple val("${id}"), val(output)
    exec:
        def thisConf = config.addTupleWithProcessHash
        output = (thisConf.operator == "+") ? input + thisConf.term : input - thisConf.term

}

workflow step8 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, [ "addTupleWithProcessHash" : [ "operator" : "-", "term" : 10 ] ] ] } \
        | addTupleWithProcessHash \
        | view{ it }

}

// step 9
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

workflow step9 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, [ "addTupleWithProcessHashScript" : [ "operator" : "-", "term" : 10 ] ] ] } \
        | addTupleWithProcessHashScript \
        | view{ it }

}

// step 10
process process_step10a {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input.toInteger() + term.toInteger()

}

process process_step10b {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input.toInteger() - term.toInteger()

}

workflow step10 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, 10 ] } \
        | process_step10a \
        | map{ id, value, term -> [ id, value, 5 ] } \
        | map{ [ it[0], it[1], 5 ] } \
        | map{ x -> [ x[0], x[1], 5 ] } \
        | process_step10b \
        | view{ it }

}

// step 11
include { process_step11 as process_step11a } from './examples/modules/step11.nf'
include { process_step11 as process_step11b } from './examples/modules/step11.nf'

workflow step11 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, [ : ] ] } \
        | map{ id, value, config -> [ id, value, [ "term" : 5, "operator" : "+" ] ] } \
        | process_step11a \
        | map{ id, value, config -> [ id, value, [ "term" : 11, "operator" : "-" ] ] } \
        | process_step11b \
        | view{ [ it[0], it[1] ] }

}

// step 12
process process_step12 {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input.sum()

}

workflow step12 {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, 10 ] } \
        | process_step10a \
        | toList \
        | map{ [ "sum", it.collect{ id, value, config -> value }, [ : ] ] } \
        | process_step12 \
        | view{ [ it[0], it[1] ] }

}

// step 13
process process_step13 {

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

workflow step13 {

    Channel.fromPath( params.input ) \
        | map{ el -> [ el.baseName.toString(), el, [ "operator" : "-", "term" : 10 ]  ]} \
        | process_step13 \
        | view{ [ it[0], it[1] ] }

}

// step 14
process process_step14 {

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

workflow step14 {

    Channel.fromPath( params.input ) \
        | map{ el -> [ el.baseName.toString(), el, [ "operator" : "-", "term" : 10 ]  ]} \
        | process_step14 \
        | view{ [ it[0], it[1] ] }

}

// step 15
process process_step15 {

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

workflow step15 {

    Channel.fromPath( params.input ) \
        | map{ el -> [ el.baseName.tostring(), el, [ "id": el.baseName, "operator" : "-", "term" : 10 ]  ]} \
        | process_step15 \
        | view{ [ it[0], it[1] ] }

}

// step 16
process process_step16 {

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

workflow step16 {

    Channel.fromPath( params.input ) \
        | map{ el -> [ el.baseName.toString(), el, [ "id": el.baseName, "operator" : "-", "term" : 10 ]  ]} \
        | process_step16 \
        | view{ [ it[0], it[1] ] }

}

// step 17
process process_step17 {

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

workflow step17 {

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
        | process_step17 \
        | view{ [ it[0], it[1] ] }

}

// step 18
def out_from_in = { it -> it.baseName + "-out.txt" }

process process_step18 {

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

workflow step18 {

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
        | process_step18 \
        | view{ [ it[0], it[1] ] }

}

// step 19
process process_step19 {

    input:
        tuple val(id), file(input), val(config)
    output:
        tuple val("${id}"), file("output.yaml"), val("${config}")
    script:
        """
        yq r ${input} f > output.yaml
        """

}

workflow step19 {

    Channel.fromPath( "/Users/toni/code/diflow/data/input.yaml" ) \
        | map{ el -> [ "id", el, [ : ] ]} \
        | process_step19 \
        | view{ [ it[0], it[1].text.trim() ] }

}

// step 20
process process_step20 {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input[0] / input[1]

}

workflow step20 {

    Channel.from( [ 1, 2 ] ) \
        | map{ el -> [ el.toString(), el, 10 ] } \
        | process_step10a \
        | toSortedList{ a,b -> a[0] <=> b[0] } \
        | map{ [ "sum", it.collect{ id, value, config -> value }, [ : ] ] } \
        | process_step20 \
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

workflow stepA2 {

    input_ = Channel.from( [ 1, 2, 3 ] )

    step1_ = runOrSkip(input_, map{ it -> it * 2 }, runOrNot, "step1")
    step2_ = runOrSkip(step1_, map{ it -> it + 5 }, runOrNot, "step2")
    step3_ = runOrSkip(step2_, map{ it -> it / 2 }, runOrNot, "step3")
    step4_ = runOrSkip(step3_, map{ it -> it + 1 }, runOrNot, "step4")
    step5_ = runOrSkip(step4_, map{ it -> it + 5 }, runOrNot, "step5")

    step5_.view{ it }

}


// ----------

process process_stepxx {

    input:
        tuple val(id), val(input), val(term)
    output:
        tuple val("${id}"), val(output), val("${term}")
    exec:
        output = input.toInteger() + term.toInteger()

}

workflow workflow_stepxx {

    take: input_

    main:
        output_ = process_stepxx(input_)

    emit:
        output_
}

workflow stepxx {

    Channel.from( [ 1, 2, 3 ] ) \
        | map{ el -> [ el.toString(), el, 10 ] } \
        | workflow_stepxx \
        | workflow_stepxx \
        | view{ it }

}





workflow stepM {

    Channel.from( params.input ) \
        | add \
        | view{ it }

}

workflow stepN {

    Channel.from(params.input) \
        | map{ it.split(",") } \
        | flatten \
        | map{ it.toInteger() } \
        | map{ i -> [ "", i, params ] } \
        | map{ [ it[0], it[1] + 1, it[2] ] } \
        | view{ it[1] }

}
