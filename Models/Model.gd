extends CollisionShape2D
class_name Model

export var model_name : String = "Model"

var is_walking : bool = false
var multiplier : float = 1

var wait_time : float
var l1 : int = 1
var l2 : int = 4


func _ready():
	wait_time = $Timer.wait_time
	$Timer.start()

func _process(delta):
	walking()

func walking():
	if is_walking and $Timer.is_stopped():
		$walk.play()
		$Timer.start(wait_time/multiplier)

		if l1 == 1:
			$leg.position = $leg_p1.position
			l1 += 2 
		elif l1 == 3:
			$leg.position = $leg_p3.position
			l1 += 2
		else:
			$leg.position = $leg_p1.position
			l1 = 3
			
		if l2 == 2:
			$leg2.position = $leg_p2.position
			l2 += 2 
		elif l2 == 4:
			$leg2.position = $leg_p4.position
			l2 += 2
		else:
			$leg2.position = $leg_p2.position
			l2 = 4
	
	elif not is_walking:
		$leg.position = $leg_p5.position
		$leg2.position = $leg_p5.position
