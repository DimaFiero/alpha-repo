extends PlayerState

func EnterState():
	state_name = "Fall"
	
func ExitState():
	player.sprite.play("ground")
	
func Draw():
	pass
	
func Update(delta: float):
	player.HandleGravity(delta, player.GRAVITY_FALL)
	player.HandleLanding()
	player.HandleJump()
	player.HandleJumpBuffer()
	HandleAnimations()
	
func HandleAnimations():
	player.sprite.play("fall")
