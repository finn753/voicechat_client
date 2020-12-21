# Created by Finn Pickart
# https://finn378.itch.io/

extends Node

onready var output = $Output
onready var timer = $Timer

var mic

func _ready():
	# Get microphone
	# See https://docs.godotengine.org/de/stable/tutorials/audio/recording_with_microphone.html to set up an microphone
	var idx = AudioServer.get_bus_index("Record")
	mic = AudioServer.get_bus_effect(idx,0)

func _process(delta):
	# Checking if the user wants to send audio (PushToTalk)
	if Input.is_action_just_pressed("mic"): # The action is defined in the project settings
		mic.set_recording_active(true) # Start the recording
		timer.one_shot = false # Keep the timer running
		timer.start() # Start the timer
	elif Input.is_action_just_released("mic"): # The action is defined in the project settings
		mic.set_recording_active(false) # Stop the recording
		timer.one_shot = true # Stop the timer after the last audio is sent

func send_voice():
	# Sending audio to the server
	mic.set_recording_active(false) # Stop the recording
	var record = mic.get_recording() # Get the recording
	Server.broadcast_audio(record.get_data(), record.get_format(), record.get_mix_rate(), record.is_stereo()) # Pass data to the server script (in this project)
	mic.set_recording_active(true) # Start the recording

func _on_Timer_timeout():
	# Send the voice every 3 seconcds (You can change the duration in the timer node)
	send_voice()
