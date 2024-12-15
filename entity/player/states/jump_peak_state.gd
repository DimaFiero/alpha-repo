extends PlayerState

func EnterState():
	state_name = "JumpPeak"
	
func ExitState():
	pass
	
func Draw():
	pass
	
func Update(_delta: float):
	player.ChangeState(states.Fall)
	
func HandleAnimations():
	pass
