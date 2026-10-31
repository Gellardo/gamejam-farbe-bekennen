# splash_effect.gd
extends CPUParticles2D

func _ready() -> void:
    emitting = true
    finished.connect(queue_free)

func setup(spawn_pos: Vector2, splash_color: Color,size:int) -> void:
    global_position = spawn_pos
    modulate = splash_color
    amount*=size
    
