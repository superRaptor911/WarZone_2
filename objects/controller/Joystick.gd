extends TextureRect

# Called when the joystick starts updating.
signal Joystick_Start;
# Called when the joystick ends/finishes updating.
signal Joystick_End;
# Called every time the joystick updates
signal Joystick_Updated;

# The radius of the circle that joystick_ring can stay within.
export (float) var radius = 40;

# The results/axes-value for the joystick. Works exactly like a controller's joystick.
var joystick_vector = Vector2();
# The touch ID for the finger/mouse being used for this joystick. (null ID = mouse)
var joystick_touch_id = null;
# A boolean for tracking whether this joystick is active or not (currently being used or not)
var joystick_active = false;

# The inner ring/part/circle of the joystick
var joystick_ring;
var joy_loaded = false


func _enter_tree():
	if not joy_loaded:
		return
	# Reset everything, and if we are using a portion of the screen, then become
	# invisible
	joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2 );
	joystick_vector = Vector2(0, 0);
	
	joystick_touch_id = null;
	joystick_active = false;
	# Emit the Joystick_End signal because the joystick is now inactive.
	emit_signal("Joystick_End");
	

func _exit_tree():
	joystick_active = false


func _ready():
	radius *= rect_scale.x
	# This code will only run in game!
	# Get the inner ring
	joystick_ring = get_node("ring");
	# Move the inner ring to the center of the joystick
	joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2 );
	# Reset the joystick vector to zero (since the joystick is in the center)
	joystick_vector = Vector2(0, 0);
	self.visible = true;
	joy_loaded = true


func get_center_of_joystick():
	# Return the center position of the joystick texture.
	return (get_rect().position + get_rect().size/2 ) - rect_global_position;


func _input(event):
	# If the event is a press/touch...
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		# We need to figure out if this is a press, or a release
		var event_is_press = true;
		
		# Figure out if this is a press or a release based on the type of input event.
		# (They happen to have the same property in this case, but it is good habit to
		# not assume they will, and therefore treat them separately)
		if event is InputEventScreenTouch:
			event_is_press = event.pressed;
		elif event is InputEventMouseButton:
			event_is_press = event.pressed;
		
		# If the event is a press...
		if (event_is_press == true):
			# If this joystick is not yet active...
			if (joystick_active == false):
				
					
				# We need to figure out where the event happened and get the event's ID
				var event_position = Vector2();
				var event_ID = null;
				
				# Get the event position and ID
				if event is InputEventScreenTouch:
					event_position = event.position;
					event_ID = event.index;
				elif event is InputEventMouseButton:
					event_position = get_global_mouse_position();
					event_ID = null;
				
				# If the event is within the radius of the joystick.
				if ( ((get_center_of_joystick() + rect_global_position) - event_position).length() <= radius):
					
					# Set the joystick event ID.
					joystick_touch_id = event_ID;
					
					# Make the joystick active.
					joystick_active = true;
					
					# Calculate the new joystick vector value, using some math to make a vector pointing from the
					# center of the joystick to the event's position, and then divide it by the joystick radius to get
					# a normalized vector.
					joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position) / radius;
					
					# Set the joystick's position
					joystick_ring.rect_global_position = event_position - (joystick_ring.rect_size/2 );
					
					# Now the joystick has just been activated, emit Joystick_Start.
					emit_signal("Joystick_Start");
		# If the event is a release...
		else:
			# If the joystick is active...
			if (joystick_active == true):
				# We need to figure out if the event has the Index we are bound to
				var event_ID = null;
				# Get the event ID
				if event is InputEventScreenTouch:
					event_ID = event.index;
				elif event is InputEventMouseButton:
					event_ID = null;
				# Figure out if it is this joystick's event
				if (joystick_touch_id == event_ID):
					# Reset everything, and if we are using a portion of the screen, then become
					# invisible
					joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2 );
					joystick_vector = Vector2(0, 0);
					
					joystick_touch_id = null;
					joystick_active = false;
					# Emit the Joystick_End signal because the joystick is now inactive.
					emit_signal("Joystick_End");
		
	
	# If the event is a motion event... (mouse/finger is moving on/across the screen)
	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		# Only bother to update if we are active/in-use
		if (joystick_active == true):
			# We need to figure out if the event has the Index we are bound to
			# and we need to get the position of the event
			var event_ID = null;
			var event_position = Vector2();
			# Get the event ID and position
			if event is InputEventScreenDrag:
				event_ID = event.index;
				event_position = event.position;
			elif event is InputEventMouseMotion:
				event_ID = null;
				event_position = get_global_mouse_position();
			# If this event is this joystick's event.
			if (event_ID == joystick_touch_id):
				
				# Check to see if the event position is within the joystick's radius.
				# If it is, update the position of the inner ring, update joystick_vector with the new values,
				# and emit the Joystick_Updated signal.
				if ( ((get_center_of_joystick() + rect_global_position) - event_position).length() <= radius):
					joystick_ring.rect_global_position = event_position - (joystick_ring.rect_size/2);
					joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position) / radius;
					emit_signal("Joystick_Updated",-joystick_vector);
				
				# If the event position is NOT within the joystick radius, we need to calculate the values
				# differently, but within the radius of the joystick (even though the event is outside it)
				#
				# We calculate the joystick vector using a normalized vector,
				# We use a normalized direction from the center to the event position and multiply it by the joystick's
				# radius so that it is on the edge of the joystick,
				# and emit the Joystick_Updated signal.
				else:
					joystick_vector = ((get_center_of_joystick() + rect_global_position) - event_position).normalized()
					
					joystick_ring.rect_global_position = get_center_of_joystick() + rect_global_position - (joystick_ring.rect_size/2 );
					joystick_ring.rect_global_position -= joystick_vector * radius;
					
					emit_signal("Joystick_Updated",-joystick_vector);
	
