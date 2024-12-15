extends PlayerState

func EnterState():
	state_name = "Idle"
	
func ExitState():
	pass
	
func Draw():
	pass
	
func Update(_delta: float):
	player.HandleFalling()
	player.HandleJump()
	#if player.jumps > 0:
		#player.ChangeState(states.Run)
	HandleAnimations()
	
func HandleAnimations():
	player.sprite.play("idle")
