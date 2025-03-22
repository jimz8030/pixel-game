extends CanvasLayer

var character_list : Array = ["1st", "2nd", "3rd", "Ancestor", "Broken", "Business", "Community", "Creature",
"Hunt", "Many", "Mark", "Medicine", "Money", "No", "Person", "Plant", "Preditor", "Shelter", "Surprise", "Tool", "Want"]

var right_answer : String
var buff_level : int
var phase : int = 1

var symbol : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#PHASE ONE


	#random symbol scene is chosen
	var chosen_char = choose(character_list)
	var char_file = "res://Scenes/Lang_Chars/" + chosen_char + ".tscn"
	symbol = load(char_file).instantiate()
	
	#chosen symbol scene is added
	$Holder/Grid.add_child(symbol)
	
	#three random wrong answers are taken
	symbol.possible_answers.shuffle()
	var choices : Array = symbol.possible_answers.slice(0,3)
	
	symbol.correct_answers.shuffle()
	
	#one random correct answer is taken
	right_answer = symbol.correct_answers.front()
	choices.insert(1, right_answer)
	choices.shuffle()

	$Answer_1.text = choices[0]
	$Answer_2.text = choices[1]
	$Answer_3.text = choices[2]
	$Answer_4.text = choices[3]

func _process(_delta: float) -> void:
	
	if phase == 2:
		if buff_level == 0:
			#PHASE ONE REPEATS FOR PHASE 2

			#All symbols are cleared
			for char_1 in $Holder/Grid.get_children():
				$Holder/Grid.remove_child(char_1)

			#random symbol scene is chosen
			var chosen_char = choose(character_list)
			var char_file = "res://Scenes/Lang_Chars/" + chosen_char + ".tscn"
			symbol = load(char_file).instantiate()

			#chosen symbol scene is added
			$Holder/Grid.add_child(symbol)

			#three random wrong answers are taken
			symbol.possible_answers.shuffle()
			var choices : Array = symbol.possible_answers.slice(0,3)

			symbol.correct_answers.shuffle()

			#one random correct answer is taken
			right_answer = symbol.correct_answers.front()
			choices.insert(1, right_answer)
			choices.shuffle()

			$Answer_1.text = choices[0]
			$Answer_2.text = choices[1]
			$Answer_3.text = choices[2]
			$Answer_4.text = choices[3]

		else:
			#GAME EVOLVES IN PHASE 2

			#All symbols are cleared
			for char_1 in $Holder/Grid.get_children():
				$Holder/Grid.remove_child(char_1)
			
			for n in range(3):
				var symbol_get = load("res://Scenes/Lang_Chars/" + symbol.compound_sentence[n] + ".tscn").instantiate()
				$Holder/Grid.add_child(symbol_get)

			right_answer = symbol.sentence_answer
			symbol.sentence_wrongs.insert(1, right_answer)
			symbol.sentence_wrongs.shuffle()

			$Answer_1.text = symbol.sentence_wrongs[0]
			$Answer_2.text = symbol.sentence_wrongs[1]
			$Answer_3.text = symbol.sentence_wrongs[2]
			$Answer_4.text = symbol.sentence_wrongs[3]
			
		phase += 1

	elif phase == 4:
		print ("Final Buff Level: " + str(buff_level))
		phase = 1

func _on_answer_1_button_down() -> void:
	if $Answer_1.text == right_answer:
		buff_level += 1
	phase += 1


func _on_answer_2_button_down() -> void:
	if $Answer_2.text == right_answer:
		buff_level += 1
	phase += 1


func _on_answer_3_button_down() -> void:
	if $Answer_3.text == right_answer:
		buff_level += 1
	phase += 1


func _on_answer_4_button_down() -> void:
	if $Answer_4.text == right_answer:
		buff_level += 1
	phase += 1

func choose(array):
	array.shuffle()
	return array.front()
