module GridFunctions

using Reexport

# the order of inclusion matters!
include("Grids.jl")
include("Functions.jl")
# include("Base.jl")

@reexport using .Grids
@reexport using .Functions

end # end of module
