extends Area2D

@export var projectile_scene: PackedScene
@export var water = 10
@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $CollisionShape2D/Label
@onready var projectiles: Node = $projectiles
@onready var timer : Timer = $Timer

const palette = [Color.RED, Color.GREEN, Color.BLUE]

signal all_drops_finished

func init(init_water:int, time: int) -> void:
    water = init_water
    timer.wait_time = 1.0 * time / water
    
func still_wet() -> bool:
    return water > 0 or projectiles.get_child_count() > 0
func tropf() -> bool:
    var rect_shape = col_shape.shape as RectangleShape2D
    if water <= 0 or not rect_shape or not projectile_scene:
        return false
    
    # Calculate a random coordinate inside the shape's boundaries
    var extents = rect_shape.size / 2.0
    var random_offset = Vector2(
        randf_range(-extents.x, extents.x),
        randf_range(-extents.y, extents.y)
    )
    
    var spawn_pos = col_shape.global_position + random_offset
    
    # Instantiate and add to scene
    var bullet = projectile_scene.instantiate()
    bullet.global_position = spawn_pos
    bullet.setup(Vector2.DOWN, palette.pick_random(), 2)
    
    #get_tree().current_scene.add_child(bullet)
    projectiles.add_child(bullet)
    water -= 1
    label.text = str(water)
    return true

func _on_timer_timeout() -> void:
    if still_wet():
        tropf()
    else:
        all_drops_finished.emit()
        $Timer.stop()
