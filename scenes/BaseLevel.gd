extends Node

signal coin_total_changed(totalCoins, collectedCoins)

export(PackedScene) var levelCompleteScene 

var playerScene = preload("res://scenes/Player.tscn")
var pauseScene = preload("res://scenes/UI/PauseMenu.tscn")
var spawnPosition = Vector2.ZERO
var currentPlayerNode = null
var totalCoins = 0
var collectedCoins = 0

func _ready():
	spawnPosition = $PlayerRoot/Player.global_position
	register_player($PlayerRoot/Player)
	coin_total_changed(get_tree().get_nodes_in_group("coin").size())

	$Flag.connect("player_won", self, "on_player_won")

func _unhandled_input(event):
	if (event.is_action_pressed("pause")):
		var pauseInstance = pauseScene.instance()
		add_child(pauseInstance)

func coin_collected():
	collectedCoins += 1
	print(totalCoins, " - ", collectedCoins)
	emit_signal("coin_total_changed", totalCoins, collectedCoins)


func coin_total_changed(newTotal):
	totalCoins = newTotal
	emit_signal("coin_total_changed", totalCoins, collectedCoins)


func register_player(player):
	currentPlayerNode = player
	currentPlayerNode.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)

func create_player():
	var playerInstance = playerScene.instance()
	$PlayerRoot.add_child(playerInstance)
	playerInstance.global_position = spawnPosition
	register_player(playerInstance)

func on_player_died():
	currentPlayerNode.queue_free()

	var timer = get_tree().create_timer(1.5)
	yield(timer, "timeout")

	create_player()

func on_player_won():
	currentPlayerNode.disable_player_input()
	var levelComplete = levelCompleteScene.instance()
	add_child(levelComplete)
