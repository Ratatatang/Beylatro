extends Node2D

var rowSize = 15
var columnSize = 7

@onready var masterScene = load("res://Scenes/Master.tscn")

func _on_start_button_pressed():
	var master = masterScene.instantiate()
	
	get_tree().root.add_child(master)
	
	master.rowSize = rowSize
	master.columnSize = columnSize
	master.bombPercent = float($UI/BombPercent.value)
	
	master.generateHexBoard()
	queue_free()

func _on_bomb_percent_value_changed(value):
	print("change bomb percent to "+str($UI/BombPercent.value))
	$UI/BombPercent/BombLabel.text = "Bomb Percentage: " + str($UI/BombPercent.value) + "%"


func _on_row_subtract_pressed():
	rowSize -= 1
	
	if(rowSize <= 0):
		rowSize = 99
	
	$"UI/Row Size".text = "[center]Row Size: " + str(rowSize)


func _on_row_add_pressed():
	rowSize += 1
	
	if(rowSize > 99):
		rowSize = 1
	
	$"UI/Row Size".text = "[center]Row Size: " + str(rowSize)


func _on_column_subtract_pressed():
	columnSize -= 1
	
	if(columnSize <= 0):
		columnSize = 99
	
	$"UI/Column Size".text = "[center]Column Size: " + str(columnSize)


func _on_column_add_pressed():
	columnSize += 1
	
	if(columnSize > 99):
		columnSize = 1
	
	$"UI/Column Size".text = "[center]Column Size: " + str(columnSize)
