extends Node2D

const hexAdjacentsEven = [
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(-1, -1),
	]

const hexAdjacentsOdd = [
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, 1),
	Vector2(-1, 1),
	Vector2(-1, 0),
	]
	
@onready var mainMenuScene = load("res://Scenes/MainMenu.tscn")
@onready var hexmap = $TileMapLayer

var rowSize = 15
var columnSize = 7

var bombPercent = 20.0

var cells = {}
var mineCells = []
var revealedCells = []

var firstHex = true

var lost = false
var won = false

enum hexTypes {EMPTY, MINE}

func _ready():
	randomize()

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		$Camera2D.position += Vector2.LEFT * delta * 300
	elif Input.is_action_pressed("ui_right"):
		$Camera2D.position += Vector2.RIGHT * delta * 300
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position += Vector2.UP * delta * 300
	elif Input.is_action_pressed("ui_down"):
		$Camera2D.position += Vector2.DOWN * delta * 300

func _input(event):
	if(event.is_action_pressed("Restart")):
		$"CanvasLayer/Restart Popup".visible = true
	elif(lost or won):
		return
	if(event.is_action_pressed("lmb") && !$"CanvasLayer/Restart Popup".visible):
		
		var cell = Vector2(hexmap.local_to_map(hexmap.get_local_mouse_position()))
		#print(cell)
		
		if(firstHex):
			firstHex = false
			
			var adjacentDirections
			var adjacentCells = [cell]
		
			if(int(cell.x) % 2 == 0):
				adjacentDirections = hexAdjacentsEven
			else:
				adjacentDirections = hexAdjacentsOdd
				
			for adjecent in adjacentDirections:
				var adjacentHex = cell + adjecent
				
				if(cells.has(adjacentHex)):
					adjacentCells.append(adjacentHex)
			
			placeMines(adjacentCells)
		
		if(revealedCells.has(cell)):
			return
		
		if(cells.get(cell) == hexTypes.EMPTY):
			chainSafe(cell)
			#print("\ntotal cells count: "+str(cells.size()))
			#print("mine cells count: "+str(mineCells.size()))
			#print("revealed cells count: "+str(revealedCells.size()))
			#print("cells to reveal: "+str(cells.size() - mineCells.size()))
				
		elif(cells.get(cell) == hexTypes.MINE):
			lost = true
			$Background.color = Color.DARK_RED
			
			for mine in mineCells:
				hexmap.set_cell(mine, 1, Vector2(2, 0))
		
		if(revealedCells.size() >= (cells.size() - mineCells.size())):
			won = true
			$Background.color = Color.LAWN_GREEN
			
			for mine in mineCells:
				if(hexmap.get_cell_atlas_coords(mine) != Vector2i(1, 0)):
					hexmap.set_cell(mine, 1, Vector2(1, 0))
		
	if(event.is_action_pressed("rmb") && !$"CanvasLayer/Restart Popup".visible):
		var cell = Vector2(hexmap.local_to_map(hexmap.get_local_mouse_position()))
		
		if(revealedCells.has(cell) or !cells.keys().has(cell)):
			return
		if(hexmap.get_cell_atlas_coords(cell) == Vector2i(1, 0)):
			hexmap.set_cell(cell, 1, Vector2(3, 0))
		else:
			hexmap.set_cell(cell, 1, Vector2(1, 0))
			
func generateHexBoard():
	hexmap.clear()
	
	for x in range(rowSize):
		for y in range(columnSize):
			hexmap.set_cell(Vector2(x, y), 1, Vector2(3, 0))
			cells[Vector2(x, y)] = hexTypes.EMPTY
	
	var camera = $Camera2D
	
	camera.limit_top = 0
	camera.limit_left = 0
	camera.limit_right = 160 + (rowSize * 74.5)
	camera.limit_bottom = 126 + (columnSize * 95)

func placeMines(avoidHexes):
	var bombAmount = round((bombPercent / 100.0) * float(cells.keys().size()))
	var placedBombs = 0
	var initialAdjacents = []
	var adjacentDirections
	
	while(placedBombs < bombAmount):
		var bombCell = cells.keys().pick_random()
		
		if(avoidHexes.has(bombCell) == false && mineCells.has(bombCell) == false):
			cells[bombCell] = hexTypes.MINE
			mineCells.append(bombCell)
			#hexmap.set_cell(bombCell, 1, Vector2(2, 0))
			placedBombs += 1

func chainSafe(start : Vector2, chain = true):
	var spotsToCheck = []
	var checkedSpots = []
	
	spotsToCheck.append(start)
	
	while(true):
		
		if(spotsToCheck.is_empty()):
			break
		
		var adjacentDirections
		var hex = spotsToCheck[0]
		spotsToCheck.remove_at(0)
		
		if(cells[hex] == hexTypes.MINE):
			continue
		if checkedSpots.has(hex):
			continue
		
		checkedSpots.append(hex)
		
		var adjacentMines = 0
		var adjacentCells = []
		
		if(int(hex.x) % 2 == 0):
			adjacentDirections = hexAdjacentsEven
		else:
			adjacentDirections = hexAdjacentsOdd
			
		for adjecent in adjacentDirections:
			var adjacentHex = hex + adjecent
				
			if(cells.has(adjacentHex)):
				if(cells.get(adjacentHex) == hexTypes.MINE):
					adjacentMines += 1
				else:
					if(!checkedSpots.has(adjacentHex)):
						adjacentCells.append(adjacentHex)
		
		if(adjacentMines == 0):
			
			if(!revealedCells.has(hex)):
				revealedCells.append(hex)
			
			hexmap.set_cell(hex, 1, Vector2(0, 0))
			if(chain):
				spotsToCheck.append_array(adjacentCells)
		else:
			if(!revealedCells.has(hex)):
				revealedCells.append(hex)
				
			hexmap.set_cell(hex, 1, Vector2(adjacentMines - 1, 1))


func _on_yes_restart_pressed():
	$"CanvasLayer/Restart Popup".visible = false
	$Camera2D.position = Vector2.ZERO
	cells = {}
	mineCells = []
	revealedCells = []
	firstHex = true
	lost = false
	won = false
	$Background.color = Color("3f3f3f")
	
	generateHexBoard()


func _on_quit_to_menu_pressed():
	get_tree().root.add_child(mainMenuScene.instantiate())
	queue_free()

func _on_no_restart_pressed():
	$"CanvasLayer/Restart Popup".visible = false
