extends Area2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
    # Connect signals (or connect them via the Node dock)
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
    if body.has_method("collect"):
        body.collect()
    else:
        print("hit terrain")
    queue_free()
