# ReadHTML

[![Build Status](https://travis-ci.com/goropikari/ReadHTML.jl.svg?branch=master)](https://travis-ci.com/goropikari/ReadHTML.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/goropikari/ReadHTML.jl?svg=true)](https://ci.appveyor.com/project/goropikari/ReadHTML-jl)
[![Codecov](https://codecov.io/gh/goropikari/ReadHTML.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/goropikari/ReadHTML.jl)
[![Coveralls](https://coveralls.io/repos/github/goropikari/ReadHTML.jl/badge.svg?branch=master)](https://coveralls.io/github/goropikari/ReadHTML.jl?branch=master)


Read HTML table into a `DataFrame`.
Inspired by [pandas](https://pandas.pydata.org/)

# Installation
```julia
import Pkg
Pkg.pkg"add https://github.com/goropikari/ReadHTML.jl"
```

# Usage
```julia
julia> using ReadHTML

julia> url = "https://gist.githubusercontent.com/goropikari/f02f29e61228a1249626a63187543fbc/raw/9ea21302243b9c57af7c6f18bbcd6e836d7f0219/ex.html";

# | No 	| Competition | John  | Adam  | Robert | Paul  |
# |----	|-------------|-------|-------|--------|-------|
# | 1  	| Swimming    |  1:30 |  2:05 |   1:15 |  1:41 |
# | 2  	| Running     | 15:30 | 14:10 |  15:45 | 16:00 |
# | 3  	|             |   70% |   55% |    90% |   88% |


julia> read_html(url)
1-element Array{DataFrame,1}:
 3×6 DataFrame. Omitted printing of 4 columns
│ Row │             No           │             Competition           │
│     │ Union{Missing, String}   │ Union{Missing, String}            │
├─────┼──────────────────────────┼───────────────────────────────────┤
│ 1   │             1            │             Swimming              │
│ 2   │             2            │             Running               │
│ 3   │             3            │                                   │
```



This package doesn't support `colspan` and `rowspan`.
If the headers of tables contain them, you should specify `header=false`.
```julia
julia> read_html(url, header=false)
```

# Other usage
```julia
tbs = gettables(url)
read_table(tbs[1], header=true)
```