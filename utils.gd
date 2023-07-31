class_name Utils

class Dict:
	static func append_to_array(dictionary: Dictionary, key: Variant, value: Variant) -> void:
		if not dictionary.has(key):
			dictionary[key] = []
		
		if typeof(value) == TYPE_ARRAY:
			dictionary[key].append_array(value)
		else:
			dictionary[key].append(value)

