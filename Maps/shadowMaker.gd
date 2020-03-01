tool
extends TileMap

var xStartingTiles = Array()
var yStartingTiles = Array()

var xEndingTiles = Array()
var yEndingTiles = Array()

var timer = Timer.new()

var old_height_array = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		add_child(timer)
		timer.connect("timeout",self,"_on_timer_timeout")
		timer.one_shot = false
		timer.start(5)

func _on_timer_timeout():
	if $height.get_used_cells() != old_height_array:
		old_height_array = $height.get_used_cells()
		clearShadows()
		getWalls()
		createShadows()
		print("updated shadow map")


func testTiles():
	for i in range(0,2):
		for j in range(0,9):
			$shadow.set_cell(i,j,0,false,false,false,Vector2(i,j))
			
func clearShadows():
	var used_tiles = $shadow.get_used_cells()
	for i in used_tiles:
		$shadow.set_cell(i.x,i.y,-1,false,false,false,Vector2(-1,-1))

class TileYsort:
	static func compare(a : Vector2,b : Vector2) -> bool:
		if a.x < b.x:
			return true
		if a.y < b.y:
			return true
		return false


#function to get walls that cast shadow
func getWalls():
	#clear arrays
	xEndingTiles.clear()
	xStartingTiles.clear()
	yStartingTiles.clear()
	yEndingTiles.clear()
	
	var used_tiles = $height.get_used_cells()
	
	#Vector2(-999,-999) is taken randomly and it is assumed that
	#there is no tile at (-999, -999)
	var prev_tile = Vector2(-999,-999)
	#get walls that cast shadow at x dir
	for i in used_tiles:
		if (i.x - prev_tile.x) != 1:
			xStartingTiles.append(i)
			if !(prev_tile.x == -999 and prev_tile.y == -999):
				xEndingTiles.append(prev_tile)
				#print(prev_tile)
		prev_tile = i
	xEndingTiles.append(prev_tile)
	
	prev_tile = Vector2(-999,-999)
	#sort for Y
	used_tiles.sort_custom(TileYsort,"compare")
	#get walls that cast shadow at y dir
	for i in used_tiles:
		if (i.y - prev_tile.y) != 1:
			yStartingTiles.append(i)
			if !(prev_tile.x == -999 and prev_tile.y == -999):
				yEndingTiles.append(prev_tile)
				#print(prev_tile)
		prev_tile = i
	yEndingTiles.append(prev_tile)

#function to place shadow blocks at place where shadow is to be casted
func createShadows():
	var shadow_tileset = $shadow
	var height_tileset = $height
	
	#place shadow blocks in x dir
	for i in xEndingTiles:
		if yStartingTiles.has(i):
			shadow_tileset.set_cell(i.x+1,i.y,0,false,false,false,Vector2(0,4))
			if  height_tileset.get_cell(i.x + 1,i.y + 1) == -1:
				shadow_tileset.set_cell(i.x+1,i.y + 1,0,false,false,false,Vector2(0,2))
		else:
			shadow_tileset.set_cell(i.x+1,i.y,0,false,false,false,Vector2(1,3))
		if yEndingTiles.has(i) and height_tileset.get_cell(i.x + 1,i.y + 1) == -1:
			shadow_tileset.set_cell(i.x+1,i.y + 1,0,false,false,false,Vector2(0,2))
	
	#place shadow blocks in y dir
	for i in yEndingTiles:
		if shadow_tileset.get_cell(i.x,i.y + 1) != -1:
			shadow_tileset.set_cell(i.x,i.y + 1,0,false,false,false,Vector2(1,5))
		elif xStartingTiles.has(i) and height_tileset.get_cell(i.x ,i.y + 1) == -1:
			shadow_tileset.set_cell(i.x,i.y + 1,0,false,false,false,Vector2(1,1))
		elif height_tileset.get_cell(i.x,i.y + 1) == -1:
			shadow_tileset.set_cell(i.x,i.y + 1,0,false,false,false,Vector2(0,0))
