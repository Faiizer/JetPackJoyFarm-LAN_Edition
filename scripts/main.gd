extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene



func _on_b_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	$HUD.hide()
	$S_Waiting.stop()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _on_b_join_pressed():
	$HUD.hide()
	$S_Waiting.stop()
	peer.create_client("192.168.255.162", 135)
	multiplayer.multiplayer_peer = peer
