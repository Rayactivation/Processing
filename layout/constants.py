# We have 30 pixels per meter but the layout lengths
# are in inches, so to convert:
# 30 pixels / m * 0.0254 m / in = 0.762 pixels / in
px_per_in = 0.762
in_per_px = 1 / px_per_in

# The LED strips are placed two inches apart
strip_spacing_inches = 2
