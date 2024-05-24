package game

import rl "vendor:raylib"

Tile :: struct {
    src: rl.Vector2,
    dst: rl.Vector2,
    flip_x: bool,
    flip_y: bool,
}

Room :: struct {
    name: string,
    music: rl.Music,
    map_pos: rl.Vector2,

    tile_offset: rl.Vector2,
    collision_tiles: []u8,
    tile_data: []Tile,

    floor_tile_offset: rl.Vector2,
    floor_tile_data: []Tile,
}

Door :: struct {
    pos: rl.Vector2,
    dest_room: Room,
    dest_player_pos: rl.Vector2,
    //dest_player_facing: u8
}

key_count: u8
candy_count: u8
has_map: bool
reason_death: string
