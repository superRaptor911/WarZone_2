class_name LinkedList
extends Node

var first = null
var last = null

var is_empty = true

func addElement(e : Dictionary):
	if not first:
		first = e
		first['next'] = first
		first['prev'] = first
		last = first
	else:
		last['next'] = e
		e['prev'] = last
		e['next'] = first
		first['prev'] = e
		last = e
	
	is_empty = false
