extends Control

var diaPath = ""
var diaSpeed = 0.03

onready var choices = [$Choices/Choice1, $Choices/Choice2, $Choices/Choice3, $Choices/Choice4, $Choices/Choice5, $Choices/Choice6]

var dialog

var currenText = ""

var finished = false
var enabled = false

# sets up the dialog, takes the path and gets the dialog

func start(dialogPath, dialogSpeed = 0.05):
	enabled = true
	print("Starting Dialog")
	diaPath = dialogPath
	diaSpeed = dialogSpeed
	setVisible("Dialog")
	$Timer.wait_time = diaSpeed
	dialog = getDialog()
	currenText = dialog
	nextPhrase()
	
# waits for the escape command to move dialog along, as
# well as for enabled to be false to stop the dialog
	
# warning-ignore:unused_argument
func _process(delta):
	if(enabled == true):
		if Input.is_action_just_pressed("escape") and $Choices.visible == false:
			if finished:
				nextPhrase()
			else:
				$Dialog.visible_characters = len($Dialog.text)
				
		if $Choices.visible == true:
			for i in len(choices):
				if(choices[i].is_hovered() == true):
					choices[i].get_node("ChoiceText").set("custom_colors/default_color",Color(1,1,0))
				else:
					choices[i].get_node("ChoiceText").set("custom_colors/default_color",Color(1,1,1))
	else:
		visible = false
		$Name.bbcode_text = ""
		$Dialog.bbcode_text = ""
		
# gets the dialog tree given a file.
# note that you only need the name and the file inside the Dialog file
# It adds the filepath and .json to that
	
func getDialog():
	var diaFile = File.new()
	diaFile.open("res://Dialog/"+str(diaPath)+".json", File.READ)
	var diaFileData = JSON.parse(diaFile.get_as_text())
	diaFile.close()
	return(diaFileData.result)
	
# loops through the characters and reveals the persons words
	
func nextPhrase(key = "", findDialogKey = false) -> void:
	
	if(findDialogKey == false):
		findDialog()
	else:
		findDialog(key)

	finished = false
	
	if($Dialog.visible == true):
		print("Revealing Dialog")
		$Dialog.visible_characters = 0
		while $Dialog.visible_characters < len($Dialog.text):
			$Dialog.visible_characters += 1
			$Timer.start()
			yield($Timer, "timeout")
		finished = true
		return
	else:
		var choiceList = []
		
		for i in len(choices):
			if(choices[i].visible == true):
				choiceList.append(choices[i].get_node("ChoiceText"))
				
		for i in len(choiceList):
			revealChoices(choiceList[i])
		
		finished = true
		return

func revealChoices(choice):
	choice.visible_characters = 0
	
	while choice.visible_characters < len(choice.text):
				choice.visible_characters += 1
				$Timer.start()
				yield($Timer, "timeout")

# gets and sets the name and dialog as well as calling events and setting
# dialog choices

func findDialog(key = "") -> void:
	
	if(key != ""):
		setVisible("Dialog")
		currenText = currenText.get(key)
		if(currenText.has("Portrait")):
			$Portrait.visible = true
			$Portrait.texture = load("res://Dialog/Portraits/"+str(currenText.get("Portrait"))+".png")
		else:
			$Portrait.visible = false
		
		if(currenText.has("Name")):
			$Name.visible = true
			$Name.bbcode_text = currenText.get("Name")
		else:
			$Name.visible = false
			
		$Dialog.bbcode_text = currenText.get("Text")
		return

	var keys = currenText.keys()
	
	if(keys.find("NextDia") >= 0):
		setVisible("Dialog")
		currenText = currenText.get(keys[keys.find("NextDia")])
		
		if(currenText.has("Portrait")):
			$Portrait.visible = true
			$Portrait.texture = load("res://Dialog/Portraits/"+str(currenText.get("Portrait"))+".png")
		else:
			$Portrait.visible = false
		
		if(currenText.has("Name")):
			$Name.visible = true
			$Name.bbcode_text = currenText.get("Name")
		else:
			$Name.visible = false
			
		$Dialog.bbcode_text = currenText.get("Text")
		return
	elif(keys.find("Decis") >= 0):
		$Dialog.bbcode_text = ""
		setVisible("Choices")
		currenText = currenText.get(keys[keys.find("Decis")])
		$Portrait.visible = false
			
		var decisKeys = currenText.keys()
		print(decisKeys)
		for i in len(decisKeys):
			choices[i].get_node("ChoiceText").bbcode_text = str(decisKeys[i])
			
		for i in len(choices)-len(decisKeys):
			choices[i+len(decisKeys)].visible = false
	else:
		enabled = false
		find_parent("Player").frozen = false
		find_parent("Player").external_set_state("move")
		visible = false

# helper function for setting the dialog or choice as the
# visible part of the dialog

func setVisible(toSet):
	visible = true
	if(toSet == "Dialog"):
		$Choices.visible = false
		$Dialog.visible = true
		$Name.visible = true
	if(toSet == "Choices"):
		$Choices.visible = true
		$Dialog.visible = false
		$Name.visible = false

func choiceManager(button):
	var choice = button.get_node("ChoiceText").bbcode_text
	print(choice)
	nextPhrase(choice, true)
	

func _on_Choice1_pressed():
	choiceManager($Choices/Choice1)


func _on_Choice2_pressed():
	choiceManager($Choices/Choice2)


func _on_Choice3_pressed():
	choiceManager($Choices/Choice3)


func _on_Choice4_pressed():
	choiceManager($Choices/Choice4)


func _on_Choice5_pressed():
	choiceManager($Choices/Choice5)


func _on_Choice6_pressed():
	choiceManager($Choices/Choice6)
