# JSONStat

[![Build Status](https://travis-ci.org/klpn/JSONStat.jl.svg?branch=master)](https://travis-ci.org/klpn/JSONStat.jl)

[![Coverage Status](https://coveralls.io/repos/klpn/JSONStat.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/klpn/JSONStat.jl?branch=master)

[![codecov.io](http://codecov.io/github/klpn/JSONStat.jl/coverage.svg?branch=master)](http://codecov.io/github/klpn/JSONStat.jl?branch=master)

This package can be used to read and write datasets in the [JSON-stat
format](https://json-stat.org/). It is intended be used with JuliaIO
[JSON](https://github.com/JuliaIO/JSON.jl),
[DataFrames](https://github.com/JuliaStats/DataFrames.jl/) and
[DataStructures](https://github.com/JuliaLang/DataStructures.jl).

To read a JSON-stat file containing a dataset.

```julia
using JSONStat
import JSON
oecdjsonstat = JSON.parsefile("test/oecd.json",
dicttype=DataStructures.OrderedDict)
oecd = readjsondataset(oecdjsonstat)
```

Parses the contents of `test/oecd.json` into an `OrderedDict`, `oecd`. The
DataFrame `oecd["datasetframe"]` will contain columns with all data dimensions
defined in `dimension` in `oecd.json` and the values defined in `value`.

Older `bundle` responses containing a map of datasets can also be read:

```julia
oecdcajsonstat = JSON.parsefile("test/oecd-canada.json",
dicttype=DataStructures.OrderedDict)
oecdca = readjsonbundle(oecdcajsonstat)
```

Dictionaries with labels for a specific category can be converted to
DataFrames, e.g. to be joined with the main `datasetframe` for a dataset:

```julia
areaframe = labelframe("area", oecd)
join(oecd["datasetframe"], areaframe, on=:area)
```

Ordered dicts with datasets can be written to JSON-stat:

```julia
JSON.json(writejsondataset(oecd), 1)
```
