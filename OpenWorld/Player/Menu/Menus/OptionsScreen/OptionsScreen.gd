extends Node2D

var player_name
onready var masterNode = get_node("/root/Master")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	masterNode.connect("player_list_changed", self, "refresh_lobby")
	masterNode.connect("connection_failed", self, "_on_connection_failed")
	masterNode.connect("connection_succeeded", self, "_on_connection_success")
	
	$Connect.show()
	$Hosting.hide()
	
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]


func _on_Host_pressed():
	if($Connect/Name.text == ""):
		$Connect/ErrorSpace.text = "Invalid name!"
		return
	
	$Connect.hide()
	$Hosting.show()
	$Connect/ErrorSpace.text = ""

	var player_name = $Connect/Name.text
	masterNode.host_game(player_name)
	refresh_lobby()


func _on_Join_pressed():
	if($Connect/Name.text == ""):
		$Connect/ErrorSpace.text = "Invalid IP!"
		return
	
	var ip = $Connect/IP.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorSpace.text = "Invalid IP address!"
		return

	$Connect/ErrorSpace.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	masterNode.join_game(ip, player_name)

func refresh_lobby():
	var players = masterNode.get_player_list()
	players.sort()
	$Hosting/PlayersList.clear()
	$Hosting/PlayersList.add_item(masterNode.get_player_name() + " (You)")
	for p in players:
		$Hosting/PlayersList.add_item(p)

func _on_connection_success():
	$Connect.hide()
	$Hosting.show()

func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorSpace.set_text("Connection failed.")
