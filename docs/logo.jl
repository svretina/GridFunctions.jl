using Luxor

function draw_sine_cosine_julia_font(filename)
    Drawing(500, 500, filename)
    origin()
    # background("white")

    # --- Settings ---
    j_purple = "#9558B2"
    j_red    = "#CB3C33"
    j_green  = "#389826"
    j_blue   = "#4063D8"
    cols = [j_purple, j_red, j_green, j_blue]

    grid_spacing = 65
    grid_extent = 3
    dot_radius = 16
    
    # --- 1. Draw Background Grid ---
    sethue("grey90")
    setline(2)
    for i in -grid_extent:grid_extent
        line(Point(i * grid_spacing, -240), 
             Point(i * grid_spacing, 240), :stroke)
        line(Point(-240, i * grid_spacing), 
             Point(240, i * grid_spacing), :stroke)
    end
    
    # --- Helper: Draw Discrete Curve ---
    function draw_curve(func, color_shift)
        points = Point[]
        for x_idx in -grid_extent:grid_extent
            x_pos = x_idx * grid_spacing
            # Negative y because Luxor y-axis points down
            y_pos = -func(x_idx) * grid_spacing 
            push!(points, Point(x_pos, y_pos))
        end

        # Connector lines
        setline(4)
        setopacity(0.4)
        for i in 1:length(points)-1
            c_idx = mod1(i + 1 + color_shift, 4)
            sethue(cols[c_idx])
            line(points[i], points[i+1], :stroke)
        end
        setopacity(1.0)

        # Dots with white outline for separation
        for (i, p) in enumerate(points)
            c_idx = mod1(i + color_shift, 4)
            sethue("white")
            circle(p, dot_radius + 3, :fill)
            sethue(cols[c_idx])
            circle(p, dot_radius, :fill)
        end
        return points
    end

    # --- 2. Define Math Functions (Sine & Cosine) ---
    # g(x) = Cosine (labeled left)
    g_math(x) = 2.0 * cos(x * 0.8 + pi/4)
    
    # f(x) = Sine (labeled bottom-right)
    f_math(x) = 2.0 * sin(x * 0.8)

    # --- 3. Draw Them ---
    pts_g = draw_curve(g_math, 0) # Color offset 0
    pts_f = draw_curve(f_math, 2) # Color offset 2

    # --- 4. Labels with "Julia" style font ---
    # We use a bold sans-serif to mimic the Julia logo's typeface.
    # Try Helvetica-Bold, fall back to Arial-Bold if needed for portability.
    try
        fontface("Helvetica-Bold")
    catch
        fontface("Arial-Bold")
    end
    
    fontsize(120) # Large and bold
    
    # Label g (Cosine)
    # Placed top-left, near the curve. 
    # pts_g[3] corresponds to x=-1
    sethue(j_purple)
    label_g_pos = Point(-100, 40) #+ pts_g[3]
    text("G", label_g_pos, halign=:center)

    # Label f (Sine)
    # Placed in the "empty space below the curves".
    # The bottom-right quadrant has good negative space.
    sethue(j_green)
    # Manual placement in the bottom right empty area
    label_f_pos = Point(15, 145)
    text("F", label_f_pos, halign=:center)

    finish()
    preview()
end

draw_sine_cosine_julia_font("./docs/src/GridFunctions_logo.svg")