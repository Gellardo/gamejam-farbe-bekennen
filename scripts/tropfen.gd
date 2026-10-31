extends Area2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.DOWN
var color: Color = Color.RED
var size: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
const SPLASH = preload("res://Splash.tscn")

func _ready() -> void:
    # Connect signals (or connect them via the Node dock)
    area_entered.connect(_on_area_entered)
    body_entered.connect(_on_body_entered)
    sprite.frame = randi_range(0,sprite.hframes-1)
    sprite.modulate = color
    sprite.set_instance_shader_parameter("phase_offset", randf() * TAU)
    _resize(size)

# Clean setup function to call right after instantiating
func setup(init_direction: Vector2, init_color: Color, init_size: int) -> void:
    direction = init_direction
    color = init_color
    _resize(init_size)
    
    # If the projectile is already inside the tree, apply immediately
    if sprite:
        sprite.modulate = color
        
func _resize(new_size):
    size = new_size
    if sprite:
        sprite.scale = Vector2(size, size)
        var capsule = collision.shape.duplicate() as CapsuleShape2D
        capsule.height *= new_size
        capsule.radius *= new_size
        collision.shape = capsule

func destroy():
    var splash = SPLASH.instantiate()
    var tint: Color = sprite.modulate
    var capsule = collision.shape as CapsuleShape2D
    splash.setup(global_position+ + Vector2(0, capsule.height * 0.5 * global_scale.y), tint, size)
    get_parent().add_child(splash)
    queue_free()

func _physics_process(delta: float) -> void:
    position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        print("hit body")
        pass
    else:
        #print("hit terrain")
        pass
    destroy()
func _on_area_entered(body: Node) -> void:
    if body.is_in_group("umbrella"):
        body = body.owner
        if body.has_method("collect"):
            body.collect(color, size)
        destroy()
