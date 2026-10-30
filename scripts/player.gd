extends CharacterBody2D


const SPEED = 300.0

var current_color = Color.BLACK

func collect(color: Color):
    current_color = current_color.lerp(color, 0.25)
    $Sprite2D.modulate = current_color
    
func _ready() -> void:
    $Sprite2D.modulate = current_color

func _physics_process(delta: float) -> void:

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var direction := Input.get_axis("left", "right")
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()
    
    var visible_rect = get_viewport_rect()
    
 
