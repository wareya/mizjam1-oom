extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.


var w = 32
var h = 16

var force_closed_chance = 20
var loop_form_chance = 20
var start_clear_radius = 2
var loop_delete_chance = 75
var max_loop_detect_size = 35
var tiny_dead_end_kill_chance = 80

var junk_density = 10
var stuff_density = 0.5
var enemy_density = 0.75


var virt_w = w*2-1
var virt_h = h*2-1

var level = []

const NULL = 0
const OPEN = 1
const ACCESSIBLE = 2
const CLOSED = 3
const FORCECLOSED = -1

var rng : RandomNumberGenerator = Manager.rng

var accessible = []

func level_set(x, y, state):
    if x >= 0 and x < virt_w and y >= 0 and y < virt_h:
        level[y][x] = state

func level_get(x, y):
    if x >= 0 and x < virt_w and y >= 0 and y < virt_h:
        return level[y][x]
    else:
        return FORCECLOSED

func level_contains(x, y):
    return x >= 0 and x < virt_w and y >= 0 and y < virt_h

func repaint_walls(x, y):
    if level_get(x-1, y) in [NULL, ACCESSIBLE]:
        if level_get(x-2, y) == NULL:
            level_set(x-1, y, ACCESSIBLE)
            accessible += [[x-1, y]]
        else:
            if level_get(x-1, y) == ACCESSIBLE:
                accessible.erase([x-1, y])
            level_set(x-1, y, CLOSED)
    
    if level_get(x+1, y) in [NULL, ACCESSIBLE]:
        if level_get(x+2, y) == NULL:
            level_set(x+1, y, ACCESSIBLE)
            accessible += [[x+1, y]]
        else:
            if level_get(x+1, y) == ACCESSIBLE:
                accessible.erase([x+1, y])
            level_set(x+1, y, CLOSED)
    
    if level_get(x, y-1) in [NULL, ACCESSIBLE]:
        if level_get(x, y-2) == NULL:
            level_set(x, y-1, ACCESSIBLE)
            accessible += [[x, y-1]]
        else:
            if level_get(x, y-1) == ACCESSIBLE:
                accessible.erase([x, y-1])
            level_set(x, y-1, CLOSED)
    
    if level_get(x, y+1) in [NULL, ACCESSIBLE]:
        if level_get(x, y+2) == NULL:
            level_set(x, y+1, ACCESSIBLE)
            accessible += [[x, y+1]]
        else:
            if level_get(x, y+1) == ACCESSIBLE:
                accessible.erase([x, y+1])
            level_set(x, y+1, CLOSED)
                

func open_random_wall():
    var index = rng.randi_range(0, len(accessible)-1)
    var chosen = accessible[index]
    accessible.remove(index)
    
    var x = chosen[0]
    var y = chosen[1]
    level_set(x, y, OPEN)
    var opened
    if x%2 == 1: # wall between cell on left and right
        if level_get(x-1, y) != OPEN:
            opened = [x-1, y]
        else:
            opened = [x+1, y]
    else: # wall between cell on left and right
        if level_get(x, y-1) != OPEN:
            opened = [x, y-1]
        else:
            opened = [x, y+1]
        
    level_set(opened[0], opened[1], OPEN)
    return(opened)

func _flood_fill_add_to_frontier(x, y, frontier, visited):
    if level_contains(x, y) and level_get(x, y) != OPEN and !visited.has([x, y]) and !frontier.has([x, y]):
        frontier[[x, y]] = null

func _flood_fill_visit(x, y, frontier, visited):
    frontier.erase([x, y])
    visited[[x, y]] = null
    _flood_fill_add_to_frontier(x-1, y, frontier, visited)
    _flood_fill_add_to_frontier(x+1, y, frontier, visited)
    _flood_fill_add_to_frontier(x, y-1, frontier, visited)
    _flood_fill_add_to_frontier(x, y+1, frontier, visited)

func flood_fill(x, y):
    var visited = {}
    var frontier = {}
    
    _flood_fill_visit(x, y, frontier, visited)
    while frontier.size() > 0:
        var coord = frontier.keys()[0]
        _flood_fill_visit(coord[0], coord[1], frontier, visited)
    
    return visited.keys()


var tile_slots = [1, 2]

var untaken_open_cells = null

func cell_distance(cellA, cellB):
    return abs(cellA[0] - cellB[0]) + abs(cellA[1] - cellB[1])

func rand_open_cell(dist_from = null, min_dist = 10):
    if untaken_open_cells == null:
        untaken_open_cells = []
        for iy in range(virt_h):
            for ix in range(virt_w):
                if level_get(ix, iy) == OPEN:
                    untaken_open_cells += [[ix, iy]]
    if len(untaken_open_cells) == 0:
        return null
    var preferred_cells = []
    if dist_from == null:
        preferred_cells = untaken_open_cells
    else:
        for cell in untaken_open_cells:
            if cell_distance(dist_from, cell) >= min_dist:
                preferred_cells += [cell]
    if len(preferred_cells) == 0:
        preferred_cells = untaken_open_cells
    
    var index = rng.randi_range(0, len(preferred_cells)-1)
    var ret = preferred_cells[index]
    
    if dist_from != null:
        print("dist is " + str(cell_distance(dist_from, ret)) + " out of " + str(min_dist))
    if preferred_cells == untaken_open_cells:
        untaken_open_cells.remove(index)
    else:
        untaken_open_cells.erase(ret)
    return ret

func add_object(object, dist_from = null, min_dist = 10) -> Array:
    var cell = rand_open_cell(dist_from, min_dist)
    
    object = object.instance()
    add_child(object)
    object.position.x = cell[0]*16
    object.position.y = cell[1]*16
    
    return cell

func _ready():
    if Manager.position < 5:
        w = 12
        h = 10
    elif Manager.position < 10:
        w = 16
        h = 13
    elif Manager.position < 15:
        w = 24
        h = 14
    else:
        w = 32
        h = 16
    if Manager.position == 19:
        stuff_density *= 2
    virt_w = w*2-1
    virt_h = h*2-1
    print ("using size %sx%s" % [w*2-1, h*2-1])
    
    rng.set_seed(hash(Manager.current_seed))
    print("Using seed \"" + Manager.current_seed + "\"")
    
    for iy in range(virt_h):
        var row = []
        for ix in range(virt_w):
            row += [0]
        level += [row]
    
    var start_x = rng.randi_range(0, w-1)*2
    var start_y = rng.randi_range(0, h-1)*2
    
    # create random obstacles to improve level path complexity
    
    for iy in range(h):
        iy *= 2
        for ix in range(w):
            ix *= 2
            if rng.randi_range(0, 99) < force_closed_chance:
                level_set(ix, iy, FORCECLOSED)
                
    # generate starting point, including clearing random obstacles too close to it
    
    for iy in range(-start_clear_radius, start_clear_radius+1):
        for ix in range(-start_clear_radius, start_clear_radius+1):
            if level_get(start_x+ix*2, start_y+iy*2) == FORCECLOSED:
                level_set(start_x+ix*2, start_y+iy*2, NULL)
    level_set(start_x, start_y, OPEN)
    repaint_walls(start_x, start_y)
    
    # generate layout
    
    while len(accessible) > 0:
        var opened = open_random_wall()
        repaint_walls(opened[0], opened[1])
    
    # make loops by randomly opening walls
    
    for iy in range(virt_h):
        for ix in range(virt_w):
            if ix%2 == iy%2 || level_get(ix, iy) != CLOSED || rng.randi_range(0, 99) >= loop_form_chance:
                continue
            level_set(ix, iy, OPEN)
            # TODO: mode that detects actual left-side-and-right-side walls?
            if ix%2 == 1:
                level_set(ix-1, iy, OPEN)
                level_set(ix+1, iy, OPEN)
            if iy%2 == 1:
                level_set(ix, iy-1, OPEN)
                level_set(ix, iy+1, OPEN)
    
    
    # exclude tiles connected to level edge from island pruning
    
    var edge_walls = {}
    
    for iy in range(virt_h):
        if level_get(0, iy) != OPEN:
            edge_walls[[0, iy]] = null
        if level_get(virt_w-1, iy) != OPEN:
            edge_walls[[virt_w-1, iy]] = null
    for ix in range(virt_w):
        if level_get(ix, 0) != OPEN:
            edge_walls[[ix, 0]] = null
        if level_get(ix, virt_h-1) != OPEN:
            edge_walls[[ix, virt_h-1]] = null
    
    var excluded_walls = {}
    
    for wall in edge_walls:
        for islandwall in flood_fill(wall[0], wall[1]):
            excluded_walls[islandwall] = null
    
    # delete random islands
    
    for iy in range(virt_h):
        for ix in range(virt_w):
            if level_get(ix, iy) == OPEN || excluded_walls.has([ix, iy]):
                continue
            var island = flood_fill(ix, iy)
            var delete = rng.randi_range(0, 99) < loop_delete_chance
            for wall in island:
                excluded_walls[wall] = null
                if delete and len(island) < max_loop_detect_size:
                    level_set(wall[0], wall[1], OPEN)
    
    # find and fill in tiny dead ends (randomly)
    
    for iy in range(h):
        iy *= 2
        for ix in range(w):
            ix *= 2
            if level_get(ix, iy) != OPEN:
                continue
            var checks = null
            if level_get(ix-1, iy) == OPEN:
                if checks != null: continue
                checks = [[-3,  0], [-2, -1], [-2,  1]]
            if level_get(ix+1, iy) == OPEN:
                if checks != null: continue
                checks = [[ 3,  0], [ 2, -1], [ 2,  1]]
            if level_get(ix, iy-1) == OPEN:
                if checks != null: continue
                checks = [[ 0, -3], [-1, -2], [ 1, -2]]
            if level_get(ix, iy+1) == OPEN:
                if checks != null: continue
                checks = [[ 0,  3], [-1,  2], [ 1,  2]]
            if checks != null:
                var open_checks = 0
                for check in checks:
                    open_checks += int(level_get(ix+check[0], iy+check[1]) == OPEN)
                if open_checks > 1:
                    if rng.randi_range(0, 99) < tiny_dead_end_kill_chance:
                        level_set(ix, iy, CLOSED)
                        level_set(ix+checks[0][0]/3, iy+checks[0][1]/3, CLOSED)
    
    # convert level data into level geometry
    for y in range(-16, virt_h+17):
        for x in range(-16, virt_w+17):
            var tile = tile_slots[0]
            if level_get(x, y) == OPEN:
                tile = tile_slots[1]
            $TileMap.set_cell(x, y, tile)
    $TileMap.fix_invalid_tiles()
    
    seed(hash(Manager.current_seed))
    $TileMap.update_bitmask_region()
    $TileMap.update_dirty_quadrants()
    
    var entrance_pos = add_object(preload("res://stuff/StairUp.tscn"))
    var exit_pos = add_object(preload("res://stuff/StairDown.tscn"), entrance_pos, (virt_w+virt_h)/2*0.5)
    
    var player_origin = entrance_pos
    if Manager.direction == "up":
        player_origin = exit_pos
    var player = preload("res://stuff/Player.tscn").instance()
    add_child(player)
    player.position.x = player_origin[0]*16
    player.position.y = player_origin[1]*16
    player.update_camera()
    
    var open_cells
    
    open_cells = len(untaken_open_cells)
    var num_junk = rng.randi_range(open_cells*junk_density/2/100, open_cells*junk_density*3/2/100)
    for i in range(num_junk):
        add_object(preload("res://stuff/Junk.tscn"))
    
    Manager.unique_randomize_rng(rng)
    
    open_cells = len(untaken_open_cells)
    var num_stuff = rng.randi_range(float(open_cells)*stuff_density/100.0, open_cells*stuff_density*1.5/100.0)
    for i in range(num_stuff):
        add_object(preload("res://stuff/Stuff.tscn"))
    
    open_cells = len(untaken_open_cells)
    var num_enemies = rng.randi_range(float(open_cells)*enemy_density/100.0, open_cells*enemy_density*1.5/100.0)
    for i in range(num_enemies):
        add_object(preload("res://stuff/Zakko.tscn"))
    
    
    


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
