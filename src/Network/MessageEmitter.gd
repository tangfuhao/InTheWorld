#负责管理socket和消息队列
class_name MessageEmitter

const PORT = 33553
var server_socket
var running := false

signal data_received(id,data)
signal disconnect(id)

#func sendAcK(_socket_id,_packect_dic):
#	var ack_data := {}
#	ack_data["cmd"] = GameState.ResponseCmd.ACK
#	ack_data["seq"] = _packect_dic["seq"]
#	var repkt = to_json(ack_data).to_utf8()
#	#TODO 这步需要设计
#	server_socket.get_peer(_socket_id).put_packet(repkt)

func sendMessage(_socket_id,_packect_dic):
	if GameState.lobby_model.is_user_login(_socket_id):
		var repkt = to_json(_packect_dic).to_utf8()
		#TODO 这步需要设计
		server_socket.get_peer(_socket_id).put_packet(repkt)
	else:
		#TODO 存储
		pass


func _init():
	create_socket()

func poll():
	if running:
		server_socket.poll()


func create_socket():
	if server_socket:
		return

	server_socket = WebSocketServer.new()
	server_socket.connect("client_connected", self, "_on_client_connected")
	server_socket.connect("client_disconnected", self, "_on_client_disconnected")
	server_socket.connect("client_close_request", self, "_on_client_close_request")
	server_socket.connect("data_received", self, "_on_data_received")
	
func start_server():
	if server_socket.is_listening():
		return
	
	# Start listening on the given port.
	var err = server_socket.listen(PORT)
	running = err == OK
	if err != OK:
		print("Unable to start server")

func stop_server():
	if server_socket.is_listening():
		server_socket.stop()


func _on_client_connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSockegame_network_handlert sub-protocol (which is optional)
	print("Client %d connected with protocol: %s" % [id, proto])


func _on_client_close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _on_client_disconnected(id, was_clean = false):
	emit_signal("disconnect",id)

func _on_data_received(id):
	# Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
	# and not get_packet directly when not using the MultiplayerAPI.
	var pkt = server_socket.get_peer(id).get_packet()
	var packect_text = pkt.get_string_from_utf8()
	emit_signal("data_received",id,packect_text)
