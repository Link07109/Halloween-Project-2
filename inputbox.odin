package game

import rl "vendor:raylib"
import "core:fmt"
import "core:unicode/utf8"

maxValues := 1
letterCount := 0
textBox := rl.Rectangle { 20, 80, 184, 40 }
framesCounter := 0

nopers: []rune
has_made_nopers: bool
input: cstring
message: cstring

inputbox_show :: proc(message_to_show: cstring, max_chars: int) {
    message = message_to_show
    maxValues = max_chars
    if !has_made_nopers {
        nopers = make([]rune, max_chars)
        has_made_nopers = true
    }

    charr := rl.GetCharPressed()
    for charr > 0 {
        if charr >= 48 && charr <= 57 && letterCount < maxValues {
            nopers[letterCount] = charr
            letterCount += 1
        }
        charr = rl.GetCharPressed()
    }

    if rl.IsKeyPressed(.BACKSPACE) {
        letterCount -= 1
        if letterCount < 0 {
            letterCount = 0
        } else if letterCount > maxValues {
            letterCount = maxValues - 1
        }
        nopers[letterCount] = '_'
    }
    framesCounter += 1

    nopers_string := utf8.runes_to_string(nopers[:])
    input = fmt.ctprintf("%v", nopers_string)

    delete(nopers_string)
    free_all(context.allocator)
}

inputbox_process :: proc(door: ^Door, correct_answer: cstring) {
    has_made_nopers = false
    delete(nopers)
    if input == correct_answer {
        rl.PlaySound(sound_correct)
        if correct_answer == "3" {
            dialogue_set_message("* Correct")
            door.src = { 160, 0, 16, 16 }
        } else {
            dialogue_set_message("* You may enter")
        }
        door := door
        door.locked_with = ""
    } else {
        if correct_answer == "3" {
            rl.PlaySound(sound_run_roar)
            timer_start(&timer_soundfx, 4)
            reason_death = "Learn how to count"
        } else {
            reason_death = "Better luck next time"
        }
        game_over()
    }
    input = ""
}

inputbox_draw :: proc() {
    dialogue_draw_input(input, message)

    // blinking
    if letterCount < maxValues {
        if (framesCounter/20)%2 == 0 {
            rl.DrawText("|", i32(textBox.x) + 4 + rl.MeasureText(input, 4), i32(textBox.y) + 4, 4, rl.WHITE)
        }
    } else {
        if (framesCounter/20)%2 == 0 {
            rl.DrawText("|", i32(textBox.x) + 4 + rl.MeasureText(input, 4), i32(textBox.y) + 4, 4, rl.RED)
        }
    }
}
