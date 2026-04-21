# Ensure a power_array has only a single fun_out value

If multiple fun_out values are present in the input take the first one.

## Usage

``` r
EnsureSingleFunOut(x, condition = "warning", sliced = FALSE)
```

## Arguments

- x:

  A power array

- condition:

  If array is not summarised should a `warning` or `error` be produced.
  Ignored if required dimensions is NULL.

- sliced:

  For the condition text should the user be informed the array is
  sliced. Ignored if required dimensions is NULL.

## Value

A power array with only a single fun_out value
