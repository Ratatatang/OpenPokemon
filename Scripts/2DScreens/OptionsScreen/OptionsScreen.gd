extends Node2D

var player_name
@onready var masterNode = get_node("/root/Master")
@onready var menuNode = get_node("/root/Master/Menu")
var ip_address

# Called when the node enters the scene tree for the first time.
func _ready():

	masterNode.connect("player_list_changed", Callable(self, "refresh_lobby"))
	get_tree().connect("connected_to_server", Callable(self, "connected_to_server"))
	
	$Connect.show()
	$Hosting.hide()
		
	ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
	
	$Hosting/HostIP.text = "Host Address: "+str(ip_address)
	
	if(masterNode.connectedToServer):
		$Connect.hide()
		$Hosting.show()
		refresh_lobby()


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
		$Connect/ErrorSpace.text = "No Name!"
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
	
	menuNode.multiplayerReady = false

func connected_to_server():
	$Connect.hide()
	$Hosting.show()

func refresh_lobby():
	var players = masterNode.get_player_list()
	players.sort()
	$Hosting/PlayersList.clear()
	$Hosting/PlayersList.add_item(masterNode.get_player_name() + " (You)")
	for p in players:
		$Hosting/PlayersList.add_item(p)
