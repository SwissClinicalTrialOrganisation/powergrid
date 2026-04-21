# Check the dimensions of a power array

Check the dimensions of a power array

## Usage

``` r
CheckArrayDim(x, required_dim = NULL, condition = "warning", sliced = FALSE)
```

## Arguments

- x:

  A power array

- required_dim:

  The number of dimensions required. If NULL just returns the number of
  dimensions.

- condition:

  If required dimensions are not correct should a `warning` or `error`
  be produced. Ignored if required dimensions is NULL.

- sliced:

  For the condition text should the user be informed the array is
  sliced. Ignored if required dimensions is NULL.

## Value

An integer for the number of dimensions
