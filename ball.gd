extends R3DRigidBody

func networked_spawn(state):
    global_transform = state.transform
    
func networked_process():
    if position.length() > 40:
        SyncManager.despawn(self)
