extends Resource
class_name BoonManager
## Manager for positive or negative stat / number modifiers.
##
## Choose either multiplicative or additive per BoonManager.

@export var multiplicative := true ## Decides if boon/bane list total should return 1.0 by default.

var boons: Dictionary[String, float] = {} ## List of all boon IDs and values.
var banes: Dictionary[String, float] = {} ## List of all bane IDs and values.


func _init(is_multiplicative: bool) -> void:
	multiplicative = is_multiplicative


func add_boon(id: String, value: float) -> void: ## Adds boon, or replaces existing boon with given ID.
	boons[id] = value


func add_bane(id: String, value: float) -> void: ## Adds bane, or replaces existing bane with given ID.
	banes[id] = value


func remove_boon(id: String) -> bool: ## Returns true if successful, and false if not.
	return boons.erase(id)


func remove_bane(id: String) -> bool: ## Returns true if successful, and false if not.
	return banes.erase(id)


func has_boon(id: String) -> bool: ## Returns true if boon exists.
	return boons.has(id)


func has_bane(id: String) -> bool: ## Returns true if bane exists.
	return banes.has(id)


func get_total() -> float: ## Add up all boons, subtract banes, and return the total. Multiplicative BoonManagers do not return totals below 0 to avoid breaking things.
	var total := 1.0 if multiplicative else 0.0
	if boons.is_empty() and banes.is_empty(): return total
	
	for boon in boons:
		total += boons[boon]
	for bane in banes:
		total -= banes[bane]
	return maxf(total, 0.0) if multiplicative else total # should BoonManager users decide if they want to keep it over 0?
