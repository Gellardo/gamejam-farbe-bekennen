extends Node

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("exit"):
        get_tree().quit()
        get_viewport().set_input_as_handled()
    if event.is_action_pressed("reset"):
        get_tree().paused = false
        get_tree().current_scene.reset()
        get_viewport().set_input_as_handled()
