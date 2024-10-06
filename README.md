# MTH229

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/mth229/229-projects/litea?labpath=00-blank-notebook.ipynb)

This repository allows you to run `Julia` through the `mybinder` service. This service is free, but a bit limited: it is resource constrained; it times out after 8-10 minutes of inactivity.

As it is resource constrained, the blank notebook pulls in a "lite" version of the `MTH229` package when the first cell is loaded. This does not include `SymPy` or `Plots`. The lite version includes a similar plotting feature through `PlotlyLight`. See the help page for `?plot` for details, but the basic interface of `Plots` is provided. There is a `SymbolicExpressions` package loaded that allows the use of symbolic variables in expressions to be used where functions normally would be. See `?@symbolic`.
