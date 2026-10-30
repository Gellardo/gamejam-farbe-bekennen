extends CharacterBody2D


const SPEED = 300.0

var current_color = Color.BLACK

func collect(color: Color):
    current_color = current_color.lerp(color, 0.25)
    $Sprite2D.modulate = current_color
    evaluate_round(current_color, Color.GREEN)
func _ready() -> void:
    $Sprite2D.modulate = current_color

func _physics_process(delta: float) -> void:

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var direction := Input.get_axis("left", "right")
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()
    
    var visible_rect = get_viewport_rect()
    
   
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
func evaluate_round(player_color: Color, target_color: Color) -> void:
    var result = calculate_color_score(player_color, target_color)
    
    print("Match Accuracy: %d%%" % result.accuracy_pct)
    print("Score: %d" % result.points)
    print("Rating: %s" % result.grade)
    
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
