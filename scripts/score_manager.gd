extends Node

const SAVE_PATH: String = "user://highscores.json"
const MAX_SCORES = 5

var high_scores = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    load_scores()

func load_scores() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        high_scores = []
        return

    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        push_error("Failed to open high scores file.")
        return

    var content = file.get_as_text()
    file.close()

    var parsed = JSON.parse_string(content)
    if parsed is Array:
        high_scores = parsed
    else:
        high_scores = []

func save_scores() -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if not file:
        push_error("Failed to write high scores file.")
        return

    var json_string = JSON.stringify(high_scores, "\t")
    file.store_string(json_string)
    file.close()

func add_score(score: int, accuracy_pct: float, grade: String) -> bool:
    var entry = {
        "score": score,
        "accuracy": accuracy_pct,
        "grade": grade,
        "timestamp": Time.get_datetime_string_from_system(false, true)
    }

    high_scores.append(entry)

    # Sort descending by score
    high_scores.sort_custom(func(a, b): return a["score"] > b["score"])

    # Keep only the top entries
    if high_scores.size() > MAX_SCORES:
        high_scores.resize(MAX_SCORES)

    save_scores()

    # Returns true if the added entry made it into the top list
    return entry in high_scores

func get_best_score() -> int:
    if high_scores.is_empty():
        return 0
    return high_scores[0].get("score", 0)
