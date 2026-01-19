# GridFunctions.jl

<img src="GridFunctions_logo.svg" align="right" width="200" alt="GridFunctions.jl Logo">

**GridFunctions.jl** is a high-performance Julia library for handling N-dimensional Cartesian grids, scalar fields (`GridFunction`), and discrete calculus operators. It provides a type-stable, zero-allocation framework for numerical analysis, simulation, and verifying discretization schemes.

## Features

*   **N-Dimensional Grids**: Unified `RectilinearGrid` support for 1D, 2D, 3D, and N-D domains.
*   **Flexible Topology**: Native support for **Periodic** and **NonPeriodic** boundary conditions.
*   **Generalized Staggering**: Arbitrary vertex/center staggering per dimension (e.g., Arakawa grids).
*   **Discrete Calculus**: Built-in, type-stable `Diff` (difference) and `Avg` (interpolation) operators that correctly handle staggering strings.
*   **Expression-like Syntax**: Perform algebraic operations (`+`, `-`, `*`, `sin`, `exp`) directly on `GridFunction` objects.
*   **Lazy Coordinates**: Efficient, iterator-based coordinate generation to minimize memory usage.

## Installation

```julia
using Pkg
Pkg.add("GridFunctions")
```

## Usage

### 1. Creating Grids

GridFunctions supports generic N-D grids with intuitive constructors.

```julia
using GridFunctions
using StaticArrays

# 1D Non-Periodic Grid (Vertex centered by default)
# Domain [0, 10], 10 cells
g1 = UniformGrid([0.0, 10.0], 10, 1) 

# 2D Periodic Grid
# x: [0, 2π], 32 cells
# y: [0, 2π], 32 cells
g2 = UniformGrid2D([0, 2π], [0, 2π], 32, 32; topology=Periodic)

# 2D Staggered Grid (Center-Center)
g_staggered = UniformStaggeredGrid2D([0, 1], [0, 1], 10, 10)
```

### 2. Defining GridFunctions

You can define scalar fields using functions or existing arrays.

```julia
# Define a Gaussian on a 2D grid
f_xy = GridFunction(g2, x -> exp(-sin(x[1])^2 - sin(x[2])^2), Periodic)

# Define from analytical function (automatically broadcasted)
func = GridFunction(g1, x -> sin(x[1]))
```

### 3. Indexing & Periodicity

Accessing grids and functions is type-stable and handles boundary conditions automatically.

```julia
# Get coordinate vector scalar
coord_1 = g1[1]        # SVector(0.0)

# Periodic Wrapping
# For a Periodic grid with 32 cells, index 33 wraps to 1.
val_wrapped = g2[33, 1] # Equivalent to g2[1, 1] for Periodic

# Bounds Checking (NonPeriodic)
# g1[12] -> Throws BoundsError
```

### 4. Discrete Calculus (Operators)

`GridFunctions` provides `Diff` and `Avg` operators that encompass the logic of staggered grids.

```julia
# Define a field on a Vertex grid
u = GridFunction(g1, x -> x[1]^2) # u = x^2

# Compute Central Difference (maps Vertex -> Center)
# du/dx approx 2x
du_dx = Diff(u, 1) 

# Check result topology
# du_dx.grid is now a Center-staggered grid
```

### 5. Algebraic Operations

`GridFunctions` behave like scalars in mathematical expressions.

```julia
u = GridFunction(g2, x -> sin(x[1]))
v = GridFunction(g2, x -> cos(x[1]))

# All operations verify grid compatibility
w = u^2 + v^2  # Result is approximately 1.0 everywhere
z = exp(u) / 2.0
```

## Operators Overview

| Operator | Description | Staggering Effect |
| :--- | :--- | :--- |
| `Diff(u, dim)` | Central difference `(u[i+1]-u[i])/h` | Flips `dim` (Vertex $\leftrightarrow$ Center) |
| `Avg(u, dim)` | Average `0.5*(u[i]+u[i+1])` | Flips `dim` (Vertex $\leftrightarrow$ Center) |
