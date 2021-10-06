python combat.py
cairo-compile combat.cairo --output combat-compiled.json
cairo-hash-program --program combat-compiled.json
cairo-run --program=combat-compiled.json --program_input=combat-input.json --layout=small --cairo_pie_output=combat.pie
cairo-run --layout=small --run_from_cairo_pie=combat.pie
cairo-sharp submit --cairo_pie combat.pie