extends Node

var _cash : int = 0

func creditCash(c):
	_cash += c

func debitCash(c) -> bool:
	if _cash >= c:
		_cash -= c
		return true
	return false

