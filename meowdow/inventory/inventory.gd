extends Resource

class_name Inv

signal updated

@export var items: Array[InvItem]

func insert(item: InvItem):
	for i in range(items.size()):
		if !items[i]:
			items[i] = item
			break
	updated.emit()
