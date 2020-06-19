//TODO: ADD OPTIONS

/*************
Initialization
*************/

// local my_config = fe.get_config();
fe.load_module("wafam/animate");
dofile(fe.script_dir +  "definitions.nut");
filter_data <- get_filter_data();
dofile(fe.script_dir + "UI/" + filter_data.platform +  "/settings.nut");

/*****
Layout
*****/

//Properties
fe.layout.width = 1920;
fe.layout.height = 1080;
local current_level = levels.games;

//Global background
local bg = fe.add_image("UI/white_pixel.png", 0, 128, 1920, 832);
bg.set_rgb(colors.bg.r, colors.bg.g, colors.bg.b);

//Title
local game_title = fe.add_surface(1368, 72);
game_title.x = 276;
game_title.y = 200;
game_title.add_image("UI/" + filter_data.platform + "/game_title_bg.png");
local game_title_text = game_title.add_text("[Title]", 0, 0, 1368, 60);
game_title_text.set_rgb(colors.title.r, colors.title.g, colors.title.b);

//Game List
game_list <- GameList(0, 296, 1920, 368);

//Controls information
local controls_text_settings = { char_size = 24, margin = 0, align = Align.MiddleLeft };

local game_list_controls_items = [
    { item_type = "image", path = "UI/Buttons/one_side.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Menu", width = 59, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/two_sides.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Select Game", width = 142, height = 40, margin = 44, settings = controls_text_settings },
    // { item_type = "image", path = "UI/Buttons/one_side.png", width = 40, height = 40, margin = 8, settings = { rotation = 180 } },
    // { item_type = "text", text = "-- ?? --", width = 72, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/b.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Back", width = 53, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/a.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Start Game", width = 127, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/l_wide.png", width = 80, height = 40, margin = 8 },
    { item_type = "image", path = "UI/Buttons/r_wide.png", width = 80, height = 40, margin = 8 },
    { item_type = "text", text = "Change Region", width = 172, height = 40, settings = controls_text_settings },
];

local menu_controls_items = [
    { item_type = "image", path = "UI/Buttons/one_side.png", width = 40, height = 40, margin = 8, settings = { rotation = 180 } },
    { item_type = "text", text = "Game List", width = 112, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/two_sides.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Select Option", width = 149, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/b.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Back", width = 53, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/a.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "OK", width = 34, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/l_wide.png", width = 80, height = 40, margin = 8 },
    { item_type = "image", path = "UI/Buttons/r_wide.png", width = 80, height = 40, margin = 8 },
    { item_type = "text", text = "Change Region", width = 172, height = 40, settings = controls_text_settings },
];

local game_list_controls = Panel(fe.layout.width / 2, 936, anchors.middle.center, game_list_controls_items);
local menu_controls = Panel(fe.layout.width / 2, 936, anchors.middle.center, menu_controls_items);
menu_controls.set_visible(false);

//Header
local header = fe.add_surface(1920, 136);
header.y = -8;
header.add_image("UI/" + filter_data.platform + "/header.png", 0, -28);
local header_down_animation = Animation(150, header, { properties = { y = { start = -8, end = 0 } }, onstop = function(anim) { top_menu.show_selector(true); }, onstart = function(anim) {
    current_level = levels.menu;
    game_list.selector.set_visible(false);
    top_menu.items[top_menu.selected_item].highlight(true);
} }, true);

local header_up_animation = Animation(150, header, { properties = { y = { start = 0, end = -8 } }, onstop = function(anim) { game_list.selector.set_visible(true); }, onstart = function(anim) {
        current_level = levels.games;
        top_menu.items[top_menu.selected_item].highlight(false);
        top_menu.show_selector(false);
} }, true);

local menu_options = {}
menu_options[0] <- { image = "UI/menu_opt_display.png", action = function() { ::print("Option 1\n"); } };
menu_options[1] <- { image = "UI/menu_opt_settings.png", action = function() { ::print("Option 2\n"); } };
menu_options[2] <- { image = "UI/menu_opt_language.png", action = function() { ::print("Option 3\n"); } };
menu_options[3] <- { image = "UI/menu_opt_legal.png", action = function() { ::print("Option 4\n"); } };
menu_options[4] <- { image = "UI/menu_opt_help.png", action = function() { ::print("Option 5\n"); } };

top_menu <- Menu(menu_options, 640, 44, 128, 92, header);

local region_flag = header.add_image("UI/Flags/" + filter_data.flag + ".png", 1360, 88);
region_flag.origin_x = region_flag.texture_width / 2;
region_flag.origin_y = region_flag.texture_height / 2;

//Footer
local footer = fe.add_image("UI/" + filter_data.platform + "/footer.png", 0, 960);

/*******************
Selector jump effect
*******************/
local selector_effect =
{
    left = fe.add_image("UI/white_pixel.png", 0, 0, 8, 8),
    top = fe.add_image("UI/white_pixel.png", 0, 0, 8, 8),
    right = fe.add_image("UI/white_pixel.png", 0, 0, 8, 8),
    bottom = fe.add_image("UI/white_pixel.png", 0, 0, 8, 8)
}

foreach(side in selector_effect)
{
    side.set_rgb(54, 255, 254);
    side.visible = false;
}

//Selector jump effect animations
local selector_effect_anims = {
    left = Animation(150, selector_effect.left, {}),
    top = Animation(150, selector_effect.top, {}),
    right = Animation(150, selector_effect.right, {}),
    bottom = Animation(150, selector_effect.bottom, {}),
}

foreach (animation in selector_effect_anims)
{
    animation.config = {
        onstart = function(anim) { anim.object.x = anim.config.properties.x.start; anim.object.y = anim.config.properties.y.start; anim.object.visible = true; },
        onstop = function(anim) { anim.object.visible = false; },
        interpolation = interpolations.linear
    };
}

function play_selector_jump(up)
{
    local start = {
        x = game_list.selector.image.x - game_list.selector.image.origin_x,
        y = game_list.selector.image.y - game_list.selector.image.origin_y + game_list.surface.y,
        w = game_list.selector.image.texture_width,
        h = game_list.selector.image.texture_height
    };

    local end = {
        x = top_menu.selector.x - top_menu.selector.origin_x,
        y = top_menu.selector.y - top_menu.selector.origin_y,
        w = top_menu.selector.texture_width,
        h = top_menu.selector.texture_height
    };

    selector_effect_anims.left.setup_properties({ x = { start = start.x, end = end.x }, y = { start = start.y, end = end.y }, height = { start = start.h, end = end.h } });
    selector_effect_anims.top.setup_properties({ x = { start = start.x, end = end.x }, y = { start = start.y, end = end.y }, width = { start = start.w, end = end.w } });
    selector_effect_anims.right.setup_properties({ x = { start = start.x + start.w - 8, end = end.x + end.w - 8 }, y = { start = start.y, end = end.y }, height = { start = start.h, end = end.h } });
    selector_effect_anims.bottom.setup_properties({ x = { start = start.x, end = end.x }, y = { start = start.y + start.h - 8, end = end.y + end.h - 8 }, width = { start = start.w, end = end.w } });

    foreach(animation in selector_effect_anims)
    {
        animation.config.interpolation = up ? interpolations.linear : interpolations.reverse;
        animation.play();
    }
}

//Fade effect when entering/exiting the layout
local fade_effect = fe.add_image("UI/white_pixel.png", 0, 0, fe.layout.width, fe.layout.height)
fade_effect.set_rgb(0, 0, 0);
local fadeout_animation = Animation(75, fade_effect, { properties = {alpha = { start = 0, end = 255 } }, onstart = function(anim) { anim.object.visible = true; } }, true);

Animation(150, fade_effect, { properties = { alpha = { start = 255, end = 0 } }, onstop = function(anim) { anim.object.visible = false; } }, true).play();

/********
Handlers
********/
fe.add_signal_handler( this, "singal_overrides" );

function singal_overrides(sig)
{
    switch(current_level)
    {
        case levels.menu:
            if(menu_signal_overrides(sig)) return true;
            break;
        case levels.games:
            if(games_signal_overrides(sig)) return true;
            break;
    }
    return global_overrides(sig);
}

function games_signal_overrides(sig)
{
    switch(sig)
    {
        case "left":
            if(blocking_animations_running()) return true;
            game_list.select_next(direction.left);
            return true;
        case "right":
            if(blocking_animations_running()) return true;
            game_list.select_next(direction.right);
            return true;
        case "up":
            if(blocking_animations_running()) return true;
            header_down_animation.play();
            play_selector_jump(true);
            game_list_controls.set_visible(false);
            menu_controls.set_visible(true);
            return true;
        case "down":
            return true;
    }
    return false;
}

function menu_signal_overrides(sig)
{
    switch(sig)
    {
        case "left":
            top_menu.select_next(direction.left);
            return true;
        case "right":
            top_menu.select_next(direction.right);
            return true;
        case "up":
            return true;
        case "select":
            top_menu.run_selected_action();
            return true;
        // case "back":
        //     return true;
        case "down":
            header_up_animation.play();
            play_selector_jump(false);
            menu_controls.set_visible(false);
            game_list_controls.set_visible(true);
            return true;
    }
    return false;
}

local exit_animation_triggered = false;
function global_overrides(sig)
{
    switch(sig)
    {
        case "prev_filter":
            fadeout_animation.play(function(anim) {
                fe.list.filter_index = (fe.list.filter_index - 1) % fe.filters.len();
                fe.set_display(fe.list.display_index);
            });
            return true;
        case "next_filter":
            fadeout_animation.play(function(anim) {
                fe.list.filter_index = (fe.list.filter_index + 1) % fe.filters.len();
                fe.set_display(fe.list.display_index);
            });
            return true;
        case "back":
            if(exit_animation_triggered) return false;
            fadeout_animation.play(function(anim) { exit_animation_triggered = true; fe.signal("back"); });
            return true;
            break;
    }
    return false;
}