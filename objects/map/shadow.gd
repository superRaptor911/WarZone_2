tool
extends TileMap

export var dynamic_update : bool = false

onready var map : TileMap = get_parent()

var _old_walls    = []
var timer : Timer = null

func _ready():
	dynamic_update = dynamic_update || Engine.editor_hint
	map = get_parent()
	if dynamic_update:
		timer = Timer.new()
		timer.wait_time = 5
		timer.connect("timeout", self, "_on_timeout")
		add_child(timer)
		timer.start()



func _isWall(tile_coord : Vector2) -> bool:
	return map.tile_set.tile_get_shape_count(map.get_cellv(tile_coord)) > 0


func _getWalls() -> Array:
	var cells = map.get_used_cells()
	var walls = []
	for i in cells:
		if _isWall(i):
			walls.append(i)
	return walls


func _clearShadows():
	var used_tiles = get_used_cells()
	for i in used_tiles:
		set_cell(i.x,i.y,-1,false,false,false,Vector2(-1,-1))


class TileYsort:
	static func compare(a : Vector2,b : Vector2) -> bool:
		if a.x < b.x:
			return true
		return a.y < b.y


func _processWalls(xEndingTiles, yEndingTiles, yStartingTiles, xStartingTiles):
	var walls = _getWalls()
	
	# Vector2(-999,-999) is taken randomly and it is assumed that
	# there is no tile at (-999, -999)
	var prev_tile = Vector2(-999,-999)
	# get walls that cast shadow at x dir
	for i in walls:
		if (i.x - prev_tile.x) != 1:
			xStartingTiles.append(i)
			if !(prev_tile.x == -999 and prev_tile.y == -999):
				xEndingTiles.append(prev_tile)
				# print(prev_tile)
		prev_tile = i
	xEndingTiles.append(prev_tile)
	
	prev_tile = Vector2(-999,-999)
	# Sort for Y
	walls.sort_custom(TileYsort,"compare")
	# Get walls that cast shadow at y dir
	for i in walls:
		if (i.y - prev_tile.y) != 1:
			yStartingTiles.append(i)
			if !(prev_tile.x == -999 and prev_tile.y == -999):
				yEndingTiles.append(prev_tile)
				#print(prev_tile)
		prev_tile = i
	yEndingTiles.append(prev_tile)


# Function to place shadow blocks at place where shadow is to be casted
func _createShadows(xEndingTiles, yEndingTiles, yStartingTiles, xStartingTiles):
	# Place shadow blocks in x dir
	for i in xEndingTiles:
		if yStartingTiles.has(i):
			set_cell(i.x+1,i.y,0,false,false,false,Vector2(0,4))
			if  !_isWall(Vector2(i.x + 1,i.y + 1)):
				set_cell(i.x+1,i.y + 1,0,false,false,false,Vector2(0,2))
		else:
			set_cell(i.x+1,i.y,0,false,false,false,Vector2(1,3))
		if yEndingTiles.has(i) and !_isWall(Vector2(i.x + 1,i.y + 1)):
			set_cell(i.x+1,i.y + 1,0,false,false,false,Vector2(0,2))
	
	# Place shadow blocks in y dir
	for i in yEndingTiles:
		if _isWall(Vector2(i.x,i.y + 1)):
			set_cell(i.x,i.y + 1,0,false,false,false,Vector2(1,5))
		elif xStartingTiles.has(i) and !_isWall(Vector2(i.x ,i.y + 1)):
			set_cell(i.x,i.y + 1,0,false,false,false,Vector2(1,1))
		elif !_isWall(Vector2(i.x ,i.y + 1)):
			set_cell(i.x,i.y + 1,0,false,false,false,Vector2(0,0))


func main():
	var xEndingTiles = []
	var yEndingTiles = []
	var xStartingTiles = []
	var yStartingTiles = []

	_clearShadows()
	_processWalls(xEndingTiles, yEndingTiles, yStartingTiles, xStartingTiles)
	_createShadows(xEndingTiles, yEndingTiles, yStartingTiles, xStartingTiles)
	listShadows()

func listShadows():
	for i in range(2):
		for j in range(6):
			set_cell(i, j, 0,false,false,false,Vector2(i,j))
			print("Placing shadow at %d , %d" % [i,j])

func _on_timeout():
	var new_walls = _getWalls()
	if _old_walls != new_walls:
		_old_walls = new_walls
		main()
		print("Updating shadow map||||")
