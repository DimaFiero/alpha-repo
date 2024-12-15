extends PlayerState

func EnterState():
	state_name = "Run"
	
func ExitState():
	pass
	
func Draw():
	pass
	
func Update(_delta: float):
	# Handle movements
	player.HandleJump()
	player.HandleFalling()
	HandleAnimations()
	#HandleIdle()

#func HandleIdle():
	#if player.velocity.y == 0 and player.velocity.x == 0:
		#player.ChangeState(states.Idle)
		
func HandleAnimations():
	player.sprite.play("run")
