extends Node

enum AttackType{NORMAL, HEAT}
const ATTACK_TEXT_COLORS = [
	Color.WHITE_SMOKE, 
	Color.ORANGE_RED,
]

const CELL_SIZE = Vector2.ONE * 60
const CELL_OFFSET = CELL_SIZE / 2
const CELL_DRAW_BORDER = Vector2.ONE * 2
const CELL_MODULATE = Color(1, 1, 1, 0.7)
const NEIBORNS_OFFSET = [
	Vector2.RIGHT, 
	Vector2.DOWN, 
	Vector2.LEFT, 
	Vector2.UP,
]
const CORNERS_OFFSET = [
	Vector2(-1, -1),
	Vector2(1, -1),
	Vector2(1, 1),
	Vector2(-1, 1),
]


var towers_selected: Array = [0, 1, 0, 1] #tower indexs
