package game

import rl "vendor:raylib"
import "core:fmt"
import "core:encoding/json"
import "ldtk"

Tile :: struct {
    src: rl.Vector2,
    dst: rl.Vector2,
    flip_x: bool,
    flip_y: bool,
}

Entity :: struct {
    identifier: string,
    src: rl.Vector2,
    dst: rl.Vector2,
    width: int,
    height: int,
}

Room :: struct {
    name: string,
    music: rl.Music,
    map_pos: rl.Vector2,
    doors: [4]Door,
    spikes: [2]Spike,

    entity_tile_offset: rl.Vector2,
    entity_tile_data: [dynamic]Entity,
    custom_tile_data: [112]Tile,
    tile_data: [112]Tile,
    collision_tiles: [112]u8,
}

Door :: struct {
    src: rl.Rectangle,
    locked_with: string,
    coll: rl.Rectangle,
    collided_with: bool,
    dest_room: ^Room,
    dest_player_pos: rl.Vector2,
}

Spike :: struct {
    coll: rl.Rectangle,
    up: bool
}

letter_count,
key_count,
candy_count: u8
has_map: bool
reason_death: cstring

hide_everything :: proc() {
    should_show_inputbox = false
    should_show_dialogue = false
    should_show_inventory = false
    should_show_map = false
}

clean_up :: proc(rooms_map: map[string]^Room) {
    rooms_map := rooms_map
    for _, room in rooms_map {
        delete(room.entity_tile_data)
    }
    //delete(rooms_map)
    if has_made_nopers {
        delete(nopers)
    }
    free_all(context.temp_allocator)
}

reset_data :: proc(rooms_map: map[string]^Room) {
    rooms_map := rooms_map
    hide_everything()
    clean_up(rooms_map)
    load_rooms()
    load_world(current_room, rooms_map)
    player_pos = { 112, 64 }
    player_sanity = 300
    key_count = 0
    candy_count = 0
    letter_count = 0
    has_map = false
    has_died = false
}

tile_size := 16
tile_columns := 14
tile_rows := 8
offset: rl.Vector2 = { 8, 8 }

load_entity_layer_ldtk :: proc(room: ^Room, rooms_map: map[string]^Room, layer: ldtk.Layer_Instance, iter: []ldtk.Entity_Instance, tile_offset: ^rl.Vector2) -> [dynamic]Entity {
    tile_offset.x = f32(layer.px_total_offset_x)
    tile_offset.y = f32(layer.px_total_offset_y)

    tiles := make([dynamic]Entity, len(iter))
    door_counter: u8
    spike_counter: u8

    for val, idx in iter {
        entity_tile := val.tile.? or_else { x = 0, y = 0 }
        tiles[idx].src.x = f32(entity_tile.x)
        tiles[idx].src.y = f32(entity_tile.y)

        tiles[idx].dst.x = f32(val.px.x)
        tiles[idx].dst.y = f32(val.px.y)

        tiles[idx].width = val.width
        tiles[idx].height = val.height
        tiles[idx].identifier = val.identifier

        if val.identifier == "Door" {
            tiles[idx].identifier = "Door"
            door := Door {
                coll = { f32(val.px.x), f32(val.px.y), f32(val.width), f32(val.height) },
                dest_room = rooms_map[val.field_instances[1].value.? or_else "Main_Hall"], 
                dest_player_pos = { f32(val.field_instances[2].value.(json.Array)[0].(i64)), f32(val.field_instances[2].value.(json.Array)[1].(i64)) },
            }
            locked_with := val.field_instances[0].value.(string) or_else ""
            switch locked_with {
                case "Key":
                    door.locked_with = "Key"
                    door.src = { 64, 128, 32, 16 }
                case "Code":
                    door.locked_with = "Code"
                    door.src = { 64, 160, 16, 16 }
                case "Puzzle":
                    door.locked_with = "Puzzle"
                    door.src = { 160, 160, 16, 16 }
            }
            room.doors[door_counter] = door
            door_counter += 1
        } else if val.identifier == "Item" {
             item_type := val.field_instances[0].value.(string) or_else "Item"
             switch item_type {
                case "Candy":
                    tiles[idx].identifier = "Candy" 
                case "Key":
                    tiles[idx].identifier = "Key" 
                case "Letter":
                    tiles[idx].identifier = "Letter" 
                case "Map":
                    tiles[idx].identifier = "Map" 
             }
        } else if val.identifier == "Interactable" {
             item_type := val.field_instances[0].value.(string) or_else "Interactable"
             switch item_type {
                case "Sign":
                    tiles[idx].identifier = "Sign" 
                case "Pot":
                    tiles[idx].identifier = "Pot" 
                case "Mirror":
                    tiles[idx].identifier = "Mirror" 
                case "Statue":
                    tiles[idx].identifier = "Statue" 
            }
        } else if val.identifier == "Spike" {
            tiles[idx].identifier = "Spike"
            room.spikes[spike_counter] = Spike { coll = { f32(val.px.x), f32(val.px.y), f32(val.width), f32(val.height) } }
            spike_counter += 1
        }
        //fmt.printf("-------- %v\n", tiles[idx].identifier)
    }
    return tiles
}

load_tile_layer_ldtk :: proc(iter: []ldtk.Tile_Instance) -> [112]Tile {
    tiles: [112]Tile
    for val, idx in iter {
        f := val.f
        tiles[idx].flip_x = bool(f & 1)
        tiles[idx].flip_y = bool(f & 2)

        tiles[idx].src.x = f32(val.src.x)
        tiles[idx].src.y = f32(val.src.y)
        tiles[idx].dst.x = f32(val.px.x)
        tiles[idx].dst.y = f32(val.px.y)
    }
    return tiles
}

draw_entity_tiles_ldtk :: proc(tileset: rl.Texture2D, tile_offset: rl.Vector2, tiles: [dynamic]Entity) {
    for val in tiles {
        src_rect := rl.Rectangle { val.src.x, val.src.y, 16, 16 }
        dst_rect := rl.Rectangle {val.dst.x + offset.x + tile_offset.x, val.dst.y + offset.y + tile_offset.y, f32(val.width), f32(val.height)}
        rl.DrawTexturePro(tileset, src_rect, dst_rect, { f32(tile_size/2), f32(tile_size/2) }, 0, rl.WHITE)
    }
}

draw_tiles_ldtk :: proc(tileset: rl.Texture2D, tiles: [112]Tile) {
    for val in tiles {
        src_rect := rl.Rectangle { val.src.x, val.src.y, 16, 16 }
        if val.flip_x {
            src_rect.width *= -1.0
        }
        if val.flip_y {
            src_rect.height *= -1.0
        }
        dst_rect := rl.Rectangle { val.dst.x + offset.x, val.dst.y + offset.y, 16, 16 }
        rl.DrawTexturePro(tileset, src_rect, dst_rect, { 8, 8 }, 0, rl.WHITE)
    }
}

handle_collisions :: proc(current_room: ^Room) {
    for row := 0; row < tile_rows; row += 1 {
        for column := 0; column < tile_columns; column += 1 {
            collider := current_room.collision_tiles[row * tile_columns + column]

            if collider == 0 || collider == 3 {
                continue
            }
            coll := rl.Rectangle { f32(column * tile_size) + offset.x - f32(tile_size) / 2.0, f32(row * tile_size) + offset.y - f32(tile_size) / 2.0, f32(tile_size), f32(tile_size) }
            //rl.DrawRectangleRec(coll, { 0, 255, 0, 75 })
            player_wall_collision(coll)
        }
    }
}
