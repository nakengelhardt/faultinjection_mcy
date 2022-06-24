Using MCY for fault injection
=============================

This is an example of how to use MCY's mutation generation not for checking testbench quality, but for verifying internal error-detection or -correction mechanisms. For general MCY documentation, see https://mcy.readthedocs.io/en/latest/index.html.

The code is written to work with both OSS CAD Suite and Tabby CAD Suite.

Design under test: comparator.v
-------------------------------

The top module ``redundant_comparator`` is a simple design that creates two identical instances of a module ``comparator`` that checks for equality of two 8-bit signals ``A`` and ``B``. If both comparators agree that they are equal, the output ``A_EQ_B`` is set, if they disagree the ``error`` output is set.


Formal test harness: test_sva
-----------------------------
The redundant comparator is tested for resistance to single-bit mutations using formal verification with sby.

``properties.sv`` contains the formal testbench. It instantiates the mutated module ``redundant_comparator`` and adds an assertion that for differing values of ``A`` and ``B``, either ``A_EQ_B`` must be low or ``error`` must be high.

As the test is run in batch mode, an additional input signal ``mutsel`` appears in the module interface, that can select between multiple mutations included in the export. (In this case this does not help performance as the solver still needs to run separately for each value of ``mutsel``, it is just used to demonstrate how to use batch mode.)

``test_sva.sby`` is the configuration file for the sby property checking tool.
As the design is combinatorial, a bounded model check of depth 1 is sufficient to check the assertion. The tasks are set up so that it can be called with an index argument (``[tasks]`` accepts regex format) that is passed to the testbench ``sva_tb`` by setting the macro ``MUTIDX`` before reading the source.

``test_sva.sh`` is the test script that is run for each batch of mutations. This calls sby to do the formal property check, but could call any other tool that can return results via bash scripting.
The mutated module is exported using the ``-c`` option, which adds the ``mutsel`` input mentioned earlier. Then, for each numbered mutation from ``input.txt``, the script writes the output status to ``output.txt``.

MCY setup: config.mcy
---------------------

This is where MCY is configured. Some notes on the setup of this project:

``[options]``
- ``size`` defines how many mutations should be selected. A value of ``0`` selects all mutations from the database. (This was actually an undocumented feature all along that I didn't know about.) However, there is still a randomized part in the selection of the signal used as control for the ``cnot0`` and ``cnot1`` mutation types, so the number of mutations generated when these are enabled still varies with the RNG seed used. (RNG seed can be set in the config file as well.)

- ``mode`` is a new option added for this example that allows restricting to a single type of mutation. Types are: ``inv``, ``const0``, ``const1``, ``cnot0``, ``cnot1``.

- ``tags`` lists the tags that are used in the [logic] section. Here I used the conventional tag names COVERED and UNCOVERED even if they don't quite match the example, as they are hardcoded in ``mcy gui`` for highlighting problematic (uncovered) mutations.

- ``select`` allows to restrict mutations to a subset of the design. It can be commented in to show that if mutations are restricted to either of the comparator submodules, the design is resistant to single-bit mutations. The only mutation that can change the result inacceptably directly modifies the top-level output.

``[script]``
The script is loaded from a separate file for debugging purposes: it can be run directly in the base directory to check that the design is loaded correctly into yosys.

The script needs to be kept minimal as even with 'light' elaboration scripts like ``prep``, yosys will recognize that the comparators are redundant and optimize away one copy.

Due to an implementation detail of the mutation generation pass, ``flatten`` is necessary when using batch testing to eliminate any submodules to the mutated module. Otherwise, the ``mutsel`` input will sometimes be added to a submodule selected for mutation instead of the top module.

Regardless of mode, either ``flatten`` or ``uniquify`` needs to be used when any module is instantiated multiple times, to make sure that the mutation only appears in one instance.

``[files]``
This lists the design files used by the script. The mcy project and the source could also be kept in separate directory trees: both relative paths, including using ``..``, and absolute paths are supported.

``[logic]``
This section is very simple, as there is only a single test. See the examples in the mcy documentation for how the lazy evaluation of results works in more complicated cases.

``[report]``
Prints a short summary of the results.

``[test test_sva]``
This test is set up to run in batches by setting the ``maxbatchsize`` parameter.
