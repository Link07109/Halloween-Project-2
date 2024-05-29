package game

import rl "vendor:raylib"
import "ldtk"

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

    wall_top_tile_offset: rl.Vector2,
    wall_top_tile_data: []Tile,

    entity_tile_offset: rl.Vector2,
    entity_tile_data: []Tile,
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

tile_size := 16
tile_columns := 20
tile_rows := 12

load_auto_layer_ldtk :: proc(layer: ldtk.Layer_Instance, tile_offset: ^rl.Vector2, tiles: ^[]Tile) {
    tile_offset.x = f32(layer.px_total_offset_x)
    tile_offset.y = f32(layer.px_total_offset_y)

    tiles^ = make([]Tile, len(layer.auto_layer_tiles))

    multiplier: f32 = f32(tile_size) / f32(layer.grid_size)
    for val, idx in layer.auto_layer_tiles {
        tiles[idx].dst.x = f32(val.px.x) * multiplier
        tiles[idx].dst.y = f32(val.px.y) * multiplier
        tiles[idx].src.x = f32(val.src.x)
        tiles[idx].src.y = f32(val.src.y)
        f := val.f
        tiles[idx].flip_x = bool(f & 1)
        tiles[idx].flip_y = bool(f & 2)
    }
}

draw_tiles_ldtk :: proc(tileset: rl.Texture2D, tile_offset: rl.Vector2, tiles: []Tile) {
    offset: rl.Vector2 = { 8, 8 }

    for val in tiles {
        src_rect := rl.Rectangle { val.src.x, val.src.y, 16, 16 }
        if val.flip_x {
            src_rect.width *= -1.0
        }
        if val.flip_y {
            src_rect.height *= -1.0
        }
        dst_rect := rl.Rectangle {val.dst.x + offset.x + tile_offset.x, val.dst.y + offset.y + tile_offset.y, f32(tile_size), f32(tile_size)}
        rl.DrawTexturePro(tileset, src_rect, dst_rect, { f32(tile_size/2), f32(tile_size/2) }, 0, rl.WHITE)
    }
}
