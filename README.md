# DiFlow

This is the home of DiFlow, a [NextFlow](https://www.nextflow.io/) [DSL2](https://www.nextflow.io/blog/2020/dsl2-is-here.html) abstraction layer. DiFlow is an attempt to make [DataFlow](https://en.wikipedia.org/wiki/Dataflow_programming) programming behave more like [Functional Reactive Programming](https://blog.danlew.net/2017/07/27/an-introduction-to-functional-reactive-programming/).

## What is DiFlow?

- An abstraction layer for NextFlow DSL2

- A set of conventions

- Tooling


## General idea

A pipeline is a combination of _modules_:

- A module contains one step in a larger process
- Each _module_ is independent
- A module can be tested
- A module runs in a dedicated and versioned container
- A module takes a _triplet_ as argument:

```
[ ID, data, config ]
```

## Documentation

Please refer to the documentation in either of these formats:

- [MarkDown](diflow.md)
- [One html file](diflow.html)
- [PDF](diflow.pdf)

## Remark

In order to use DiFlow efficiently, it is recommended to generate the NextFlow module code rather than manually code it. We use __`viash`__ for this and will open source it early 2020.
