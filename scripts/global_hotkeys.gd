extends Node


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("exit"):
        get_tree().quit()
        get_viewport().set_input_as_handled()
