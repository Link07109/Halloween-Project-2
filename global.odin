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

    custom_floor_tile_offset: rl.Vector2,
    custom_floor_tile_data: []Tile,

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
offset: rl.Vector2 = { 8, 8 }
//offset.x = f32(f32(screen_width) - f32(tile_size * tile_columns)) / 2

load_entity_layer_ldtk :: proc(layer: ldtk.Layer_Instance, iter: []ldtk.Entity_Instance, tiles: ^[]Tile) {
    tiles^ = make([]Tile, len(iter))

    for val, idx in iter {
        entity_tile := val.tile.? or_else { x = 0, y = 0 }
        tiles[idx].src.x = f32(entity_tile.x)
        tiles[idx].src.y = f32(entity_tile.y)

        tiles[idx].dst.x = f32(val.px.x)
        tiles[idx].dst.y = f32(val.px.y)
    }
}

load_tile_layer_ldtk :: proc(layer: ldtk.Layer_Instance, iter: []ldtk.Tile_Instance, tile_offset: ^rl.Vector2, tiles: ^[]Tile) {
    tile_offset.x = f32(layer.px_total_offset_x)
    tile_offset.y = f32(layer.px_total_offset_y)

    tiles^ = make([]Tile, len(iter))

    multiplier: f32 = f32(tile_size) / f32(layer.grid_size)
    for val, idx in iter {
        f := val.f
        tiles[idx].flip_x = bool(f & 1)
        tiles[idx].flip_y = bool(f & 2)

        tiles[idx].dst.x = f32(val.px.x) * multiplier
        tiles[idx].dst.y = f32(val.px.y) * multiplier
        tiles[idx].src.x = f32(val.src.x)
        tiles[idx].src.y = f32(val.src.y)
    }
}

draw_tiles_ldtk :: proc(tileset: rl.Texture2D, tile_offset: rl.Vector2, tiles: []Tile) {
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

handle_collisions :: proc(current_room: ^Room) {
    for row := 0; row < tile_rows; row += 1 {
        for column := 0; column < tile_columns; column += 1 {
            collider := current_room.collision_tiles[row * tile_columns + column]

            if collider != 0 {
                coll := rl.Rectangle {f32(column * tile_size) + offset.x + current_room.tile_offset.x - f32(tile_size) / 2.0, f32(row * tile_size) + offset.y + current_room.tile_offset.y - f32(tile_size) / 2.0, f32(tile_size), f32(tile_size)}
                //rl.DrawRectangleRec(coll, { 255, 10, 10, 25 })
                player_collision(coll)
            }
        }
    }
}
