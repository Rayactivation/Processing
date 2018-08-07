# We have 30 pixels per meter
px_per_m = 30

m_per_in = 0.0254
dm_per_in = m_per_in * 10

px_per_dm = px_per_m / 10
dm_per_px = 1 / px_per_dm

# px_per_in = px_per_m * m_per_in
# in_per_px = 1 / px_per_in

# The LED strips are placed two inches apart
_strip_spacing_inches = 2
strip_spacing_dm = _strip_spacing_inches * dm_per_in

