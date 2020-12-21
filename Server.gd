# Created by Finn Pickart
# https://finn378.itch.io/

extends Node

onready var voicechat = get_node("/root/Voice/VoiceChat") #Get the Voicechat node

const PORT = 31400 # The port on wich the server runs
const ADRESS = "127.0.0.1" # 127.0.0.1 is your local ip || You can insert your server ip here

const COMPRESSION = 0 # Audio compression mode (0-3) || See https://docs.godotengine.org/de/stable/classes/class_file.html#enum-file-compressionmode

func _ready():
	# Connect the signals to functions
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("connection_failed",self,"_connection_failed")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	
	create_client() # Create the client

func create_client():
	# Creating the network client and connect to the server
	print("Create client")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ADRESS,PORT)
	get_tree().network_peer = peer

remote func play_voip(data,format,mix_rate,stereo,bsize):
	# Recieve audio and play it
	# Only 1 person can talk at a time
	# You need more AudioStreamPlayer to play more audios at a time
	
	var audioStream = AudioStreamSample.new() # Creating the AudioStreamSample
	audioStream.data = data.decompress(bsize,COMPRESSION) # Set the data and decompress it
	audioStream.set_format(format) # Set the format
	audioStream.set_mix_rate(mix_rate) # Set the mix_rate
	audioStream.set_stereo(stereo) # Set if its stereo
	
	# Play audio
	voicechat.output.set_stream(audioStream) # Pass the audio to the AudioStreamPlayer
	voicechat.output.play(0) # Play the audio

func broadcast_audio(data,format,mix_rate,stereo):
	# Send audio to the server
	# Id 1 is always the server
	rpc_id(1,"broadcast_audio",get_tree().get_network_unique_id(),data.compress(COMPRESSION),format,mix_rate,stereo,data.size())

func _connected_to_server():
	print("Succesfully connected to server")

func _connection_failed():
	print("Connection failed")

func _server_disconnected():
	print("Server disconnected")
