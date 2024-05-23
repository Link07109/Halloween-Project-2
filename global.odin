package game

import rl "vendor:raylib"

Room_Name :: enum {
    Main_Hall,
    Balcony,
    Basement,
    Bathroom,
    Bedroom,
    Gallery,
    Left_Room,
    Secret_Room,
    Storage_Closet,
    Library,
    Upper_Chamber,
    Upstairs_Hallway,

    Title_Screen,
    Game_Over_Screen,
}

Room :: struct {
    name: Room_Name,
    music: rl.Music,
    texture: rl.Texture2D,
    map_pos: rl.Vector2,
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
