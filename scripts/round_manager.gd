extends Node2D

@onready var spawner = $Cloud
@onready var player = $Player
@onready var target: ColorRect = $HUD/TargetColor

@onready var popup = $HUD/GameOverPopup
@onready var result_label = $HUD/GameOverPopup/VBoxContainer/ResultLabel
@onready var restart_button = $HUD/GameOverPopup/VBoxContainer/RestartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    start_new_round()
    spawner.all_drops_finished.connect(_on_all_drops_finished)
    restart_button.pressed.connect(reset)
func _on_all_drops_finished():
    trigger_game_end()
    
func start_new_round():
    spawner.init(100, 10)
    target.color = ColorManager.get_random_color()
    
func trigger_game_end():
    var target_color = target.color
    var player_color = player.current_color
    popup.visible = true
    evaluate_round(player_color, target_color, result_label)
    get_tree().paused = true
    
    # Animate popup open
    popup.modulate.a = 0
    var tween = create_tween()
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(popup, "modulate:a", 1.0, 0.5)
    tween.tween_callback(restart_button.grab_focus)

func reset():
    get_tree().paused = false
    get_tree().reload_current_scene()
  
##############
# Scoring    #
############## 
const MAX_RGB_DIST: float = 1.7320508 # sqrt(3)

func calculate_color_score(player_color: Color, target_color: Color) -> Dictionary:
    # 1. Convert colors to 3D vectors (ignoring alpha)
    var v1 = Vector3(player_color.r, player_color.g, player_color.b)
    var v2 = Vector3(target_color.r, target_color.g, target_color.b)
    
    # 2. Euclidean distance between the two colors
    var dist = v1.distance_to(v2)
    
    # 3. Calculate normalized accuracy (1.0 = perfect match, 0.0 = completely opposite)
    var accuracy = clampf(1.0 - (dist / MAX_RGB_DIST), 0.0, 1.0)
    
    # alternative hsv calc
    var hue_diff = absf(player_color.h - target_color.h)
    if hue_diff > 0.5:
        hue_diff = 1.0 - hue_diff
    var hue_score = 1.0 - (hue_diff / 0.5) # 1.0 = same hue, 0.0 = opposite hue
    # Saturation & Value differences (0.0 to 1.0)
    var sat_score = 1.0 - absf(player_color.s - target_color.s)
    var val_score = 1.0 - absf(player_color.v - target_color.v)
    # Weight them: 60% Hue, 20% Saturation, 20% Brightness
    var hsv_score = (hue_score * 0.65) + (sat_score * 0.25) + (val_score * 0.1)
    print(hsv_score," ", hue_score, " ", sat_score, " ", val_score)
    accuracy = hsv_score
    
    # 4. Map accuracy to points (e.g. 0 to 1000 points)
    var points = int(accuracy * 1000)
    
    # 5. Assign arcade-style ratings
    var grade = "F"
    if accuracy >= 0.95:
        grade = "PERFECT!"
    elif accuracy >= 0.85:
        grade = "GREAT"
    elif accuracy >= 0.70:
        grade = "GOOD"
    elif accuracy >= 0.50:
        grade = "OK"

    return {
        "accuracy_pct": roundf(accuracy * 100.0), # e.g. 94.0%
        "points": points,
        "grade": grade,
        "raw_distance": dist
    }

# When round ends, or player reaches the goal gate:
func evaluate_round(player_color: Color, target_color: Color, label: Label) -> void:
    var result = calculate_color_score(player_color, target_color)
    var is_high_score = ScoreManager.add_score(result.points, result.accuracy_pct, result.grade, target_color, player_color)
    
    $HUD/GameOverPopup/VBoxContainer/HBoxContainer/ColorRect.color = player_color
    $HUD/GameOverPopup/VBoxContainer/HBoxContainer/ColorRect2.color = target_color
    label.text = """
    --- ROUND OVER ---
    Accuracy: {accuracy_pct}%
    Score: {points}
    Grade: {grade}
    """.format(result)
    var highscore = "\n"
    if true or is_high_score:
        highscore += """
        !1!!!!!!!
        NEW HIGH SCORE
        !!!!!!1!!
        """.dedent() + "\n"
    for i in range(min(5, ScoreManager.high_scores.size())):
        var entry = ScoreManager.high_scores[i]
        highscore += "#%1d %4d pts  (%8s - %3d%%)\n" % [
            i + 1,
            entry["score"],
            entry["grade"],
            entry["accuracy"]
        ]
    $HUD/GameOverPopup/VBoxContainer/HighScoreLabel.text = highscore
    await get_tree().process_frame # allow correct positions to settle in vbox
    fly_color_rect($HUD/TargetColor, $HUD/GameOverPopup/VBoxContainer/HBoxContainer/ColorRect2)
    
    # Bonus: Check if within a win tolerance threshold
    if result.accuracy_pct >= 85.0:
        print("Round Passed! Advancing to next color...")
    else:
        print("Color mismatch! Try again.")
func get_perceptual_distance(c1: Color, c2: Color) -> float:
    var r_diff = (c1.r - c2.r) * 0.30
    var g_diff = (c1.g - c2.g) * 0.59
    var b_diff = (c1.b - c2.b) * 0.11
    
    # Normalized perceptual distance
    return sqrt(r_diff * r_diff + g_diff * g_diff + b_diff * b_diff)    

func fly_color_rect(from: ColorRect, to: ColorRect):
#func fly_color_to_target(from_global_pos: Vector2, target_rect: ColorRect, fly_color: Color, duration: float = 0.4) -> void:
    #to.visible = false
    to.color= Color.TRANSPARENT
    
    var duration = 0.6
    var dummy = ColorRect.new()
    dummy.color = from.color
    dummy.size = from.size
    dummy.global_position = from.global_position
    $HUD/GameOverPopup.add_child(dummy)
    
    # 4. Create parallel tween
    var tween = create_tween().set_parallel(true)
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(dummy, "global_position", to.global_position, duration)
    tween.tween_property(dummy, "size", to.size, duration)
    
    # 5. Clean up automatically on completion
    # Re-enable sequential chaining so callback fires after animations complete
    tween.chain().tween_callback(dummy.queue_free)
    tween.tween_callback(func(): to.color = from.color)
