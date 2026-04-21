# Ensure a power_array is summarized

Ensure a power_array is summarized

## Usage

``` r
EnsureSummarized(x, summary_function = NULL, condition = "warning")
```

## Arguments

- x:

  A power array

- summary_function:

  What function should be used to summarize the array, if it is not
  already summarized.

- condition:

  If array is not summarised should a `warning` or `error` be produced.
  Ignored if required dimensions is NULL.

## Value

A summarised power_array
