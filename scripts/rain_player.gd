# procedural_rain_player.gd
extends AudioStreamPlayer

@export_range(0.0, 1.0) var rain_intensity: float = 0.6
@export_range(0.0, 2.0) var droplet_volume: float = 1.0
# Number of droplet taps to target per second:
@export var drops_per_second: float = 25.0

var generator_playback: AudioStreamGeneratorPlayback
var sample_rate: float = 44100.0

# 3-pole pink noise filter for the continuous ambient rain
var b0: float = 0.0
var b1: float = 0.0
var b2: float = 0.0

class DropHit:
    var amp: float = 0.0
    var filter: float = 0.0
    var cutoff: float = 0.3
    var decay: float = 0.9992 # ~15-25 ms audible tap
    var active: bool = false

var active_drops: Array[DropHit] = []
const MAX_CONCURRENT_DROPS: int = 16

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_PAUSABLE

    var stream_gen := AudioStreamGenerator.new()
    stream_gen.mix_rate = sample_rate
    stream_gen.buffer_length = 0.1
    stream = stream_gen

    for i in range(MAX_CONCURRENT_DROPS):
        active_drops.append(DropHit.new())

    play()
    generator_playback = get_stream_playback() as AudioStreamGeneratorPlayback

func _trigger_drop() -> void:
    for drop in active_drops:
        if not drop.active:
            drop.active = true
            drop.filter = 0.0
            # Surface brightness (lower = dull mud thud, higher = crisp puddle splash)
            drop.cutoff = randf_range(0.2, 0.45)
            # Decay rate keeps it snappy without instant vanishing
            drop.decay = randf_range(0.9988, 0.9994)
            # Amplitude scaled by droplet volume
            drop.amp = randf_range(0.3, 0.6) * droplet_volume
            break

func _process(_delta: float) -> void:
    if not generator_playback:
        return

    var frames_to_fill: int = generator_playback.get_frames_available()
    
    # Exact probability per sample frame based on target drops per second
    var drop_prob: float = (drops_per_second * rain_intensity) / sample_rate

    for _i in range(frames_to_fill):
        var white: float = randf_range(-1.0, 1.0)

        # 1. Continuous rain bed (smooth pink noise)
        b0 = 0.99765 * b0 + white * 0.0990460
        b1 = 0.96300 * b1 + white * 0.1963220
        b2 = 0.57000 * b2 + white * 0.3326190
        var rain_bed: float = (b0 + b1 + b2) * 0.04 * rain_intensity

        # 2. Trigger individual drops based on per-second rate
        if randf() < drop_prob:
            _trigger_drop()

        # 3. Sum active drop transients
        var drops_sample: float = 0.0
        for drop in active_drops:
            if drop.active:
                var drop_noise: float = randf_range(-1.0, 1.0)
                drop.filter += (drop_noise - drop.filter) * drop.cutoff
                drops_sample += drop.filter * drop.amp
                drop.amp *= drop.decay
                
                if drop.amp < 0.005:
                    drop.active = false

        var mixed: float = clampf(rain_bed + drops_sample, -1.0, 1.0)
        generator_playback.push_frame(Vector2(mixed, mixed))
