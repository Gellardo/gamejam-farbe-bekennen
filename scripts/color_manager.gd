class_name ColorManager
extends RefCounted

const palette = [Color.RED, Color.GREEN, Color.BLUE]

static func get_random_color() -> Color:
    return get_hue_random_color()
    
static func get_realistic_random_color():
    var c = Color.LIGHT_GRAY
    for i in range(10):
        c = color_blend(c, palette.pick_random(), 0.1)
    return c
static func get_hue_random_color() -> Color:
    var hue = randf()                             # Full rainbow: 0.0 to 1.0
    var saturation = randf_range(0.7, 1.0)        # Keeps color rich, avoids gray/white
    var value = randf_range(0.7, 1.0)             # Keeps color bright, avoids dark sludge
    return Color.from_hsv(hue, saturation, value, 1.0)

static func color_blend(base: Color, new: Color, strength: float) -> Color:
    return base.lerp(new, strength)
