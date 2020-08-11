Launch [![Binder](https://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/mth229/229-projects/S20)


MTH229 Projects

These are a collection of `IJulia` notebooks to support the MTH229 class at the College of Staten Island

They can be cloned and run on a local jupyter or jupyterhub installation.

They can be used within binder by clicking the link above.

## Questions and Answers

Question and answers are now presented and completed through  `WeBWork`.
These  notebooks only contain the background details  and many blank cells. New blank cells  can
be added through   the `Insert` menu.

There  are a few idiosyncracies to be aware of:

*  The code examples  are typset in `WeBWorK` as though they  appear in  a *terminal*. A terminal displays  the output of  each  command immediately after execution. In a notebook,  when  a cell  is executed, all the  commands are computed and *only*  the  last  value is shown. (The use of `@show` or `print(...)` can be used to display intermediate values in a  cell.)

* Copy and paste from `WeBWorK` into a notebook will usually be unsuccessful, as  numbers  in the  font  used to display computer markup do not copy as ASCII numbers  into a cell. The numbers can be hand edited though.


* While `Julia` is very happy to express its output using scientific notation, `WeBWorK` is not happy to receive the exact output for an answer. Either replace `e` with `E` (as in `1.23e4` would be `1.23E4`) or use decimals.


* For *most* questions with a  numeric answer  it is best to  copy all  16 digits of output. Several  digits after the decimal point are expected to match a  correct answer (an absolute tolerance of 0.0001 is used). For numeric questions where an  estimate is made, say from a graph, this is  significantly relaxed.

* If the answer  is to  be a function, the  automatic grader is  expecting just  the  rule  of the function  (an expression).

