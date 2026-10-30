extends Node

func _read() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("exit"):
        get_tree().quit()
        get_viewport().set_input_as_handled()
    if event.is_action_pressed("reset"):
        print("hi")
        get_tree().paused = false
        get_tree().current_scene.reset()
        get_viewport().set_input_as_handled()
