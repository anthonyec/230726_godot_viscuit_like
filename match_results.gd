class_name MatchResults

# TODO: Tidy this up, but it's sorta alright being hidden away in this class.
var instance_ids: Array[int] = []
var instance_id_to_rules: Dictionary = {}
var instance_id_to_affected_instance_ids: Dictionary = {}
var instance_id_to_has_multi_rule: Dictionary = {}

func add(instance_id: int, affected_instance_ids: Array[int], rule: Rule) -> void:
	if not instance_ids.has(instance_id):
		instance_ids.append(instance_id)
		
	if rule.has_multiple_drawings():
		instance_id_to_has_multi_rule[instance_id] = true
		
		for affected_instance_id in affected_instance_ids:
			instance_id_to_has_multi_rule[affected_instance_id] = true
	
	Utils.Dict.append_to_array(
		instance_id_to_rules,
		instance_id,
		rule
	)
	
	Utils.Dict.append_to_array(
		instance_id_to_affected_instance_ids,
		instance_id,
		affected_instance_ids
	)

func has(instance_id: int) -> bool:
	return instance_ids.has(instance_id)
	
func is_part_of_multi_rule(instance_id: int) -> bool:
	return instance_id_to_has_multi_rule.has(instance_id)
	
func get_results() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	
	for instance_id in instance_ids:
		var drawing = instance_from_id(instance_id) as Drawing
		var rules = instance_id_to_rules.get(instance_id, []) as Array[Rule]
		
		if is_part_of_multi_rule(instance_id):
			rules = rules.filter(func(rule: Rule):
				return rule.has_multiple_drawings()
			)
		
		results.append({
			"drawing": drawing,
			"rules": rules
		})
		
	return results
