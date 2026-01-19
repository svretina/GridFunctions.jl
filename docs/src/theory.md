# Theory

## Finite Difference Discretization

`GridFunctions.jl` is built around the concept of **staggered grids**, widely used in computational fluid dynamics and electromagnetics (e.g., Yee lattice) to preserve symmetries and conservation laws.

### Grid Definitions

We define two primary types of grid points in 1D:

1.  **Vertex (Collocated) Points**:
    The standard discretization of the domain $[x_{min}, x_{max}]$.
    $$ x_i = x_{min} + (i-1)h, \quad i=1, \dots, N+1 $$
    where $h = \frac{x_{max}-x_{min}}{N}$.

2.  **Center (Staggered) Points**:
    Points located at the midpoint between vertices.
    $$ x_{i+1/2} = x_{min} + (i-0.5)h, \quad i=1, \dots, N $$

In `GridFunctions`, a generic **N-dimensional** grid is defined by a tuple of booleans (Shifts), indicating whether each dimension $d$ is vertex-centered (`false`) or cell-centered (`true`).

### Discrete Operators

We implement mimetic operators that map fields between these grid types.

#### Central Difference (`Diff`)

The central difference operator approximates the derivative $\partial_x$ with second-order accuracy. It maps properties from a Vertex grid to a Center grid (and vice versa).

$$ (\text{Diff}_x u)_{i+1/2} = \frac{u_{i+1} - u_i}{h} $$

If $u$ is defined on vertices, $\text{Diff}_x u$ naturally lives on cell centers.

#### Averaging (`Avg`)

The averaging operator interpolates values between grid types.

$$ (\text{Avg}_x u)_{i+1/2} = \frac{u_{i+1} + u_i}{2} $$

### Boundary Conditions

Boundary conditions are handled via the grid topology:

*   **NonPeriodic**: Bounds checking is enforced. Indices outside the valid range throw an error.
*   **Periodic**: Indices are wrapped modulo $N$.
    $$ u_{N+1} \equiv u_1 $$
    This effectively models a domain on a torus.
