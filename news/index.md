# Changelog

## powergrid 0.5.2

Corrected listing in readme and vignette. \# powergrid 0.5.1 Small
update, making readme in line with CRAN status package. \# powergrid
0.5.0 - Added Richard Charles Allen as contributor and maintainer. -
Fixed one typo in description.

## powergrid 0.4.0

- Omitted all settings of par(), including graphics::layout() (PowerPlot
  and GridPlot)
- Argument shades_legend removed as argument to PowerPlot. The related
  function to add a legend to the grey scale is omitted too. This legend
  is difficult to position without setting par. Also, the use of such
  legend is very limited, since the eye is notoriously bad in seeing the
  equality or difference between shades when they do not share a border.
  (PowerPlot)
- Omitted (conditional) set.seed() in PowerGrid. This seed was set for
  cases where there happens to be no .Random.seed yet. Slightly tweaky
  circumvented by always drawing one uniform number before doing
  anything. \# powergrid 0.3.0
- performed all checks as listed in issue
  [\#55](https://github.com/SwissClinicalTrialOrganisation/powergrid/issues/55)
  Release powergrid 0.3.0

## powergrid 0.2.1

- only typos

## powergrid 0.2.0

This is a large, but still minor update. Some arguments have been
renamed and one function has a new name. Vignette has been improved
greatly, and all documentation has been updated and extended.
Cross-referencing in Documentation is improved. Warnings and
documentation is more consistent now.

Not that this is a Beta release. Use
`remotes::install_github("SwissClinicalTrialOrganisation/powergrid", ref = "v0.2.0")`
to install it. The package is very soon to be sumbitted to CRAN. No
changes at the user side are planned.

### Breaking Changes

- [`SummarizeIterations()`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/SummarizeIterations.md)
  replaces the older `SummarizeSims`. Iterations may, but must not be
  simulations. Language is consistency adjusted throughout the package.
  In documentation, as well as in attributes of `power_array` objects,
  “sim” is, where relevant, replaced by “iter”.
- Central argument names have changed in Example, PowerPlot, GridPlot,
  AddExample and FindTarget:
  - `find_lowest` replaces `find_min`
  - `target_at_least` replaces `minimal_target`
  - `target_value` replaces `target`
- Compatibility with sse package was omitted. see is offline and is not
  updated. Keeping all working with eventual sse output was too
  error-prone for little use.

### Improvements user level

- All help files were improved
- Vignette was extended and improved
- Tests included! (thanks Richard!)
- Input handling of all functions and respective errors and warnings was
  improved.
- PowerPlot and Example naturally deal with one-dimensional
  `power_array` object. PowerPlot has a special figure to represent the
  one-dimensional situation.

### Improvements under the hood

- The plotting of examples inside
  [`PowerPlot()`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/PowerPlot.md)
  is now handled by `AddExample`.
- Summarizing across dimenstions inside `power_grid` is now performed by
  [`SummarizeIterations()`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/SummarizeIterations.md)
  (Thanks Richard!)

### bug fixes

- A multitude of bugs were fixed
