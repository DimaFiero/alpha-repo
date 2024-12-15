extends PlayerState

func EnterState():
	state_name = "Jump"
	player.velocity.y = player.jump_speed
	
func ExitState():
	pass
	
func Draw():
	pass
	
func Update(delta: float):
	player.HandleGravity(delta)
	HandleJumpToFall()
	HandleAnimations()

func HandleJumpToFall():
	if player.velocity.y >= 0:
		player.ChangeState(states.JumpPeak)
	if !player.key_jump:
		player.velocity.y *= player.VARIABLE_JUMP_MULTIPLIER
		player.ChangeState(states.Fall)
		
func HandleAnimations():
	player.sprite.play("jump")
	player.sprite.play("fall")
