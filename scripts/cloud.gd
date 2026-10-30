extends Area2D

@export var projectile_scene: PackedScene
@onready var col_shape: CollisionShape2D = $CollisionShape2D

func tropf():
    var rect_shape = col_shape.shape as RectangleShape2D
    if not rect_shape or not projectile_scene:
        return
    
    # Calculate a random coordinate inside the shape's boundaries
    var extents = rect_shape.size / 2.0
    var random_offset = Vector2(
        randf_range(-extents.x, extents.y),
        randf_range(-extents.y, extents.y)
    )
    
    var spawn_pos = col_shape.global_position + random_offset
    
    # Instantiate and add to scene
    var bullet = projectile_scene.instantiate()
    bullet.global_position = spawn_pos
    bullet.direction = Vector2.DOWN # Or customize per wave
    
    get_tree().current_scene.add_child(bullet)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_timer_timeout() -> void:
    tropf()
