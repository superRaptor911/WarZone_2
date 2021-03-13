extends Node

# ...........Server.............
# When server is created
signal server_created
# When failed to create server
signal server_not_created
# When connected to server
signal connected_to_server
# When disconnected from server
signal disconnected_from_server

# ...........scripts/res.............
# When level is loaded
signal level_loaded
# When resource file is loaded
signal resources_loaded
# When spawnmanger is loaded
signal spawnmanger_loaded
# When sync script is loaded
signal syncscript_loaded

# ...........Player signals.............
# When player joins the server
signal player_connected(id)
# When player leaves the server
signal player_disconnected(id)
# When player is created
signal player_created(name)

# When player is created
signal entity_created(name)
# When entity is destroyed
signal entity_destroyed(name)
# When entity is killed
signal entity_killed(victim_name, killer_name, wpn_name)
# When entity is revived
signal entity_revived(name)
