Wagon
=====

Introduction
------------

In a conventional concatenative language, every symbol represents
a function which takes program states to program states, and the program
is a concatenation (sequential composition) of such functions.
This is fine when it comes to manipulating state, but what about control?

One can allow individual functions to be defined and named seperately,
then applied, perhaps conditionally and perhaps recursively.  While
this is conventional in the world of concatenative languages, such
languages are arguably no longer purely concatenative (a subject
explored by [Carriage][] and [Equipage][]).

If one wishes the language to remain purely concatenative, it seems one
must store control structures in the state (for example, [Equipage][]
stores functions on the stack) or, more drastically, allow the function
that is being constructed, to be examined somehow during the construction
process.  Functions typically aren't considered examinable in this way,
but even so, examining it this way is not very different from putting
a copy of the program itself in the state.

**Wagon** is an experiment with a third option: *second-order functions*.
Instead of functions which take states to states, the symbols of the
language represent functions which take functions from states to states,
to functions that take states to states.  The state is merely a stack of
integers, and the program is purely a concatenation of functions.

My hope was that these second-order functions could express control in
addition to expressing state manipulation.  This does turn out to be the
case, but only to a degree.  As far as I have been able to determine,
they can express some control structures, but not arbitrary ones.

Fundamentals of Wagon
---------------------

Talking about functions that themselves work on functions is admittedly somewhat
awkward, so let's define some terms.  Let's call a function that takes states
to states an _operation_.  Let's call a function that takes operations to
operations a _macro_.  A Wagon program, then, consists of a sequence of symbols,
each of which represents a macro.  These individual macros are concatenated
(sequentially composed) to form a single macro.

Since a macro takes operations to operations, it's not possible to "run" a macro
directly.  So, when asked to "run" or "evaluate" a Wagon program,
we take the following convention: apply the macro that the Wagon program represents
to the identity function, and apply the resulting function to an initial stack.
We may allow a Wagon program to accept input by supplying it on the initial stack,
but usually the initial stack is just empty.  The output is usually a depiction
of the final state of the stack.

Many of the primitive macros in Wagon are based directly on operations.  There are
two main ways we "lift" an operation _k_ to a macro.  The first is a macro which takes
an operation _o_ and returns an operation which performs _o_ then performs _k_ —
we call this sort of macro an _after-lifting_ of _k_.  The second is a macro which
takes an operation _o_ and returns an operation which performs _k_ then performs _o_ —
we call this sort of macro a _before-lifting_ of _k_.

Wagon's convention is that after-lifted operations are represented by lowercase letters,
and before-lifted operations are represented by uppercase letters.  Macros which do not
clearly fall into either of these two categories are represented by punctuation symbols.

Primitive Macros of Wagon
-------------------------

    -> Tests for functionality "Evaluate Wagon Program"

    -> Functionality "Evaluate Wagon Program" is implemented by
    -> shell command "bin/wagon run %(test-body-file)"

    -> Functionality "Evaluate Wagon Program" is implemented by
    -> shell command "bin/wagon eval %(test-body-file)"

Note that in the following examples, the `===>` line is not part of the program;
instead it shows the expected result of running each program.  In the expected
result, the resulting stack is depicted top-to-bottom.

### Rudimentary Arithmetic ###

`i` is a macro which takes an operation _o_ and returns an operation which
performs _o_ then pushes a 1 onto the stack.

`s` is a macro which takes an operation _o_ and returns an operation which
performs _o_ then pops _a_ from the stack then pops _b_ from the stack and
pushes _b_ - _a_.

With these we can construct some numbers.

    i
    ===> [1]

    iis
    ===> [0]

    iis is
    ===> [-1]

    i iis is s
    ===> [2]

As you can see, `i` and `s` are after-lifted operations.  There are also
before-lifted counterparts of them:

`I` is a macro which takes an operation _o_ and returns an operation which
pushes a 1 onto the stack then performs _o_.

`S` is a macro which takes an operation _o_ and returns and operation which
pops _a_ from the stack then pops _b_ from the stack and pushes _b_ - _a_
then performs _o_.

    SII
    ===> [0]

Note also that whitespace maps to the identity function (a macro which takes
an operation and returns that same operation) so is effectively insignificant
in a Wagon program.

### Rudimentary Stack Manipulation ###

`p` is an after-lifting of the operation: pop a value from the stack and discard it.

    i iis iis iis ppp
    ===> [1]

`P` is the before-lifted counterpart to `p`.

    PI
    ===> []

`d` is an after-lifting of the operation: duplicate the top value on the stack.

    iis ddd
    ===> [0,0,0,0]

`D` is the before-lifted counterpart to `d`.

    DDDI
    ===> [1,1,1,1]

### Sophisticated Stack Manipulation ###

`r` is an after-lifted operation: it pops a value _n_ from the stack. Then it
pops _n_ values from the stack and temporarily remembers them.  Then it
reverses the remainder of the stack.  Then it pushes those _n_ remembered
values back onto the stack.  _n_ must be zero or one.

    iis i iiisiss
    ===> [2,1,0]

    iis i iiisiss   iis r
    ===> [0,1,2]

    iis i iiisiss   i r
    ===> [2,0,1]

`R` is the before-lifted counterpart to `r`.

    I SII
    ===> [1,0]

    R SII I SII
    ===> [0,1]

### Rudimentary Control Flow ###

`@` (pronounced "while") is a macro which takes an operation _o_ and returns
an operation that repeatedly performs _o_ as long as there are elements on
the stack and the top element of the stack is non-zero.

    p@ I I I SII SII
    ===> [0,0]

An "if" can be constructed by writing a "while" that, first thing it does is,
pop the non-zero it detected, and last thing it does is, push a 0 onto the
stack.  Then immediately afterwards, pop the top element of the stack (which
we know must be zero because we know the loop just exited, whether it was
executed once, or not at all.)

Computational Class
-------------------

When Wagon was first formed, it was not clear if it would be Turing-complete
or not.  The author observed it was possible to translate many programs
written in [Loose Circular Brainfuck][] into Wagon, using the following
correspondence:

    +        iisiss
    -        is
    >        iisrir
    <        iriisr
    x[y]z    y@Xz

Loose Circular Brainfuck is Turing-complete, so if this correspondence
was total, Wagon would be shown Turing-complete too.  However, the correspondence
is not total.

It's the `@` that's the problem.  We can construct a "while" loop
with contents, and with operations that happen before it,
and with operations that happen after it.  And the contents can themselves
contain a nested "while" loop.  But we cannot place a second "while" loop
*after* an already-given "while" loop.  That is, we cannot have more than
one "while" loop on the same nesting level.

This might be best illustrated with a depiction of the nested structure that
a Wagon program represents.

    -> Tests for functionality "Depict Wagon Program"

    -> Functionality "Depict Wagon Program" is implemented by
    -> shell command "bin/wagon depict %(test-body-file)"

    p@ I I I SII SII
    ===> Push1 Push1 Sub Push1 Push1 Sub Push1 Push1 Push1 (while Pop)

    is@I  is@I
    ===> Push1 (while Push1 (while Push1 Sub) Push1 Sub)

    isis@I  @I
    ===> Push1 (while Push1 (while Push1 Sub Push1 Sub))

    i@Dp
    ===> Dup (while Push1) Pop

    i@Dp i@Dp
    ===> Dup (while Dup (while Push1) Pop Push1) Pop

While it is possible to simulate a universal Turing machine with only a
single top-level "while" loop and a series of "if" statements inside the
body of the "while" (see, for example, [Burro][]), it is not known to me
if it is possible to simulate a universal Turing machine with only
strictly-singly-nested "while" loops as constructible in Wagon.

Any inner "while" loop can be turned into an "if" as described above,
but a conventional "if/else" is not possible, because it would normally
require two consecutive "while"s, one to check the condition, and one
to check the inverse of the condition.  Similarly, it would not be
possible to check if the finite control of a Turing machine is in one
state, or another state.  This would seem to be a fairly serious restriction.

However, shortly after being announced in the `#esoteric` IRC channel, it was
[shown by int-e](https://gist.github.com/int-e/e4ae1f40f8173d67860d8f8e45c433c0)
that it is possible to compile a Tag system into a Wagon program.
Since Tag systems are Turing-complete, Wagon is as well.

As of this writing, it remains unclear if Wagon is able to simulate a
Turing machine or Loose Circular Brainfuck program directly rather than
via a Tag system.

[Loose Circular Brainfuck]: https://esolangs.org/wiki/Loose_Circular_Brainfuck_(LCBF)
[Carriage]: https://catseye.tc/node/Carriage
[Equipage]: https://catseye.tc/node/Equipage
[Burro]: https://catseye.tc/node/Burro
