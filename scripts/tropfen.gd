extends Area2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.DOWN
var color: Color = Color.RED
var size: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
    # Connect signals (or connect them via the Node dock)
    body_entered.connect(_on_body_entered)
    sprite.modulate = color
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
        capsule.radius *= 2
        capsule.radius *= 2
        collision.shape = capsule


func _physics_process(delta: float) -> void:
    position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
    if body.has_method("collect"):
        body.collect(color)
    else:
        print("hit terrain")
    queue_free()
