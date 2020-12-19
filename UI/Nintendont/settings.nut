settings <- {
    background = {
        color = { r = 250, g = 241, b = 226 }
    },
    title = {
        color = { r = 0, g = 0, b = 0 }
    },
    game_list = {
        width = fe.layout.width,
        height = 368,
        slot = {
            width = 340,
            offset = { w = 120, h = 8 },
            art = {
                origin = { x = 8, y = 16 },
                max = { w = 304, h = 272 }
            },
            players = { origin = { x = -232, y = -300 } }
        },
        selector = { origin = { x = 8, y = 8 } }
    },
    miniatures = {
        max_visible = 24,
        max_side = 80,
        selector_distance = 28,
        movement_margin = 3
    },
    controls_info = {
        image = { spacing = 8 },
        label = {
            height = 40,
            spacing = 44,
            color = { r = 167, g = 0, b = 0 },
            text = {
                char_size = 24,
                margin = 0,
                align = Align.MiddleLeft
            }
        }
    }
}