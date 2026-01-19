# Examples

## 1. 1D Differentiation

Compute the derivative of $f(x) = \sin(x)$ on a periodic domain $[0, 2\pi)$.

```julia
using GridFunctions
using StaticArrays

# Create a periodic grid with 100 cells
g = UniformGrid([0.0, 2π], 100, 1; topology=Periodic)

# Define function u = sin(x)
u = GridFunction(g, x -> sin(x[1]))

# Compute derivative
# Note: Diff(u, 1) returns a function on the Staggered grid
du_num = Diff(u, 1)

# Analytical derivative on the staggered grid
# We can evaluate cos(x) directly on the new grid for comparison
du_ana = GridFunction(du_num.grid, x -> cos(x[1]))

# Check error
err = du_num - du_ana
println("Max Error: ", maximum(abs.(err.values)))
```

## 2. 2D Laplacian

We can construct the discrete Laplacian $\nabla^2 = \partial_x^2 + \partial_y^2$ by composing `Diff` operators.
Note: $\text{Diff}_x$ maps Vertex $\to$ Center. Applying it again maps Center $\to$ Vertex.

```julia
# 2D Periodic Grid 32x32
g = UniformGrid2D([0, 2π], [0, 2π], 32, 32; topology=Periodic)

u = GridFunction(g, x -> sin(x[1]) * cos(x[2]))

# Laplacian u = d/dx(du/dx) + d/dy(du/dy)
# First Derivatives (Staggered in X or Y)
dx_u = Diff(u, 1)
dy_u = Diff(u, 2)

# Second Derivatives (Back to Vertex grid)
dxx_u = Diff(dx_u, 1)
dyy_u = Diff(dy_u, 2)

# Laplacian
lap_u = dxx_u + dyy_u

# Analytical Laplacian: -(sin(x)cos(y) + sin(x)cos(y)) = -2u
@assert isapprox(lap_u, -2.0 * u; atol=0.1)
```
