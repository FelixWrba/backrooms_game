extends Node

@onready var player: CharacterBody3D = $"../../player"
const smiler = preload("uid://b8lldogimavgu")

const chunkSize = 8
const renderDistance = 8

var chunkOptions = [
	load("res://chunks/0.tscn"),
	load("res://chunks/1.tscn"),
	load("res://chunks/2.tscn"),
	load("res://chunks/3.tscn"),
	load("res://chunks/4.tscn"),
	load("res://chunks/5.tscn"),
	load("res://chunks/6.tscn"),
	load("res://chunks/7.tscn"),
	load("res://chunks/8.tscn"),
	load("res://chunks/9.tscn"),
	load("res://chunks/11.tscn"),
	load("res://chunks/12.tscn"),
]
var darkChunks = {
	6: Vector3(1.0, 1.5, 0.0),
	7: Vector3(0.0, 1.5, 0.0),
	8: Vector3(0.0, 1.5, 0.2),
	12: Vector3(0.0, 1.5, 0.0),
}
var chunkWalls = [
	[0, 0, 0, 0],
	[0, 0, 0, 0],
	[0, 1, 0, 0],
	[0, 1, 0, 0],
	[0, 1, 1, 0],
	[0, 1, 1, 0],
	[0, 1, 0, 0],
	[0, 1, 0, 1],
	[0, 1, 0, 1],
	[0, 1, 0, 1],
	[0, 0, 0, 0],
	[0, 1, 1, 1],
]
var chunkWallLookup = createWalllLookup()
var chunks = {}

func _ready() -> void:
	seed(754)
	
func _process(_delta: float) -> void:
	var playerPos := getPlayerPosition()
	var start = { 'x': playerPos.x - renderDistance, 'z': playerPos.z - renderDistance }
	var end = { 'x': playerPos.x + renderDistance, 'z': playerPos.z + renderDistance }
	
	removeChunks(start, end)
	spawnChunks(start, end)

func createWalllLookup() -> Dictionary:
	var lookup = {
		0: {
			0: {
				0: {0: [], 1: []},
				1: {0: [], 1: []},
			},
			1: {
				0: {0: [], 1: []},
				1: {0: [], 1: []},
			}
		},
		1: {
			0: {
				0: {0: [], 1: []},
				1: {0: [], 1: []},
			},
			1: {
				0: {0: [], 1: []},
				1: {0: [], 1: []},
			}
		}
	}
	for i in chunkWalls.size():
		for angle in 4:
			var chunkWall = moveArray(chunkWalls[i], angle)
			lookup[chunkWall[0]][chunkWall[1]][chunkWall[2]][chunkWall[3]].append({ 'id': i, 'angle': angle * 90 })

	return lookup

func moveArray(array: Array, shift: int) -> Array:
	if shift == 0: return array
	
	var movedArray := [0, 0, 0, 0]
	
	movedArray[0] = array[shift % 4]
	movedArray[1] = array[(shift + 1) % 4]
	movedArray[2] = array[(shift + 2) % 4]
	movedArray[3] = array[(shift + 3) % 4]
	
	return movedArray

func getPlayerPosition() -> Dictionary:
	return {
		'x': floor(player.position.x / chunkSize), 
		'z': floor(player.position.z / chunkSize)
	}

func spawnChunks(start: Dictionary, end: Dictionary) -> void:
	for x in range(start.x, end.x):
		for z in range(start.z, end.z):
			if chunks.has(x) and chunks[x].has(z):
				continue
			createChunk(x, z)

func removeChunks(start: Dictionary, end: Dictionary):
	var xRange = range(start.x, end.x)
	var zRange = range(start.z, end.z)
	for chunkX in chunks:
		for chunkZ in chunks[chunkX]:
			if chunkX in xRange and chunkZ in zRange:
				continue
			remove_child(chunks[chunkX][chunkZ].node)
			chunks[chunkX].erase(chunkZ)
 
func createChunk(x: int, z: int) -> void:
	const wallProbability = 0.3
	const smilerProbability = 1
	
	var top := int(randf() < wallProbability)
	var right := int(randf() < wallProbability)
	var bottom := int(randf() < wallProbability)
	var left := int(randf() < wallProbability)
	
	if chunks.has(x - 1) and chunks[x - 1].has(z):
		var chunk = chunks[x - 1][z]
		top = moveArray(chunkWalls[chunk.id], chunk.angle / 90)[2]
	if chunks.has(x) and chunks[x].has(z + 1):
		var chunk = chunks[x][z + 1]
		right = moveArray(chunkWalls[chunk.id], chunk.angle / 90)[3]
	if chunks.has(x + 1) and chunks[x + 1].has(z):
		var chunk = chunks[x + 1][z]
		bottom = moveArray(chunkWalls[chunk.id], chunk.angle / 90)[0]
	if chunks.has(x) and chunks[x].has(z - 1):
		var chunk = chunks[x][z - 1]
		left = moveArray(chunkWalls[chunk.id], chunk.angle / 90)[1]
	
	var possibleChunks = chunkWallLookup[top][right][bottom][left]
	var selectedChunk = { 'id': 0, 'angle': 0 }
	if possibleChunks.size() != 0:
		selectedChunk = possibleChunks[randi_range(0, possibleChunks.size() - 1)]
	
	var chunkInstance: Node = chunkOptions[selectedChunk.id].instantiate()
	chunkInstance.position.x = x * chunkSize
	chunkInstance.position.z = z * chunkSize
	chunkInstance.rotation.y = deg_to_rad(selectedChunk.angle)
	add_child(chunkInstance)
	
	if darkChunks.has(selectedChunk.id) and randf() < smilerProbability:
		var smilerInstance =  smiler.instantiate()
		smilerInstance.position = darkChunks[selectedChunk.id]
		chunkInstance.add_child(smilerInstance)
	
	if not chunks.has(x):
		chunks[x] = {}
		
	chunks[x][z] = {'id': selectedChunk.id, 'node': chunkInstance, 'angle': selectedChunk.angle}
