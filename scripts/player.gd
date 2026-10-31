extends CharacterBody2D

const SPEED = 500.0

@onready var visuals = $Visuals
@onready var umbrella = $Visuals/SpriteUmbrella
@onready var dynamic_umbrella = $Area2D/CollisionPolygon2D

var touch_target_x = 0.0
var is_touching = false

var current_color = Color.LIGHT_GRAY
var drops = 0
var facing_direction = 1

func _unhandled_input(event: InputEvent):
    if event is InputEventScreenTouch:
      is_touching = event.pressed
    if is_touching:
      touch_target_x = get_global_mouse_position().x
    elif event is InputEventScreenDrag and is_touching:
      touch_target_x = get_global_mouse_position().x

func collect(color: Color, size: int):
    current_color = ColorManager.color_blend(current_color, color, size*0.1)
    umbrella.modulate = current_color
    
func set_facing(dir: int, delta) -> void:
    if dir == 0 or dir == facing_direction and absf(visuals.scale.x) == 1:
        return
    facing_direction = sign(dir)
    # Flips both Top and Bottom sprites simultaneously without desyncing
    # Including the hurtbox is fine since it is not involved in moving,
    # only projectile collisions. It flips together with the sprites
    visuals.scale.x = lerp(visuals.scale.x, 1.0*facing_direction, 30.0*delta)
    
func _ready() -> void:
    umbrella.modulate = current_color
    if dynamic_umbrella:
        dynamic_umbrella.shape = dynamic_umbrella.shape.duplicate()

func _physics_process(delta: float) -> void:

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var direction := Input.get_axis("left", "right")
    if is_touching:
        var diff: float = touch_target_x - global_position.x
        if abs(diff) > 10:
            direction = sign(diff)
            
    if direction:
        velocity.x = direction * SPEED
        set_facing(direction, delta)
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()
