/*******
Settings
*******/
class UserConfig </ help="Settings" /> {
	</ label="Select Button", help="Select button to show for Select action.", options="a,b,x,y,l,l_wide,r,r_wide,select,start,one_side,two_sides", order=1 />
	select_button="a";
	</ label="Cancel Button", help="Select button to show for Back action.", options="a,b,x,y,l,l_wide,r,r_wide,select,start,one_side,two_sides", order=2 />
	back_button="b";
	</ label="Previous Filter Button", help="Select button to show for Previous Filter action.", options="a,b,x,y,l,l_wide,r,r_wide,select,start,one_side,two_sides", order=3 />
	prev_filter_button="r_wide";
	</ label="Next filter Button", help="Select button to show for Next Filter action.", options="a,b,x,y,l,l_wide,r,r_wide,select,start,one_side,two_sides", order=4 />
	next_filter_button="l_wide";
}
config <- fe.get_config();

/*************
Initialization
*************/

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

// TODO: Move this properties to settings or a table
// slot_width = 340;
// slot_offset = 120;
// art_max_width = 304;
// art_max_height = 272;
// local mini_art_max_side = 52;
// vsiible_miniatures = 30;
// miniature_movement_margin = 3;

//Game List
game_list <- GameList(0, 296, fe.layout.width, 368, 340, 120, 304, 272);

//Miniature list
local miniature_list = MiniatureList(fe.layout.width / 2, 700, 56, 28, 30, 3);

//Controls information
local controls_text_settings = { char_size = 24, margin = 0, align = Align.MiddleLeft };

local game_list_controls_items = [
    { item_type = "image", path = "UI/Buttons/one_side.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Menu", width = 59, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/two_sides.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Select Game", width = 142, height = 40, margin = 44, settings = controls_text_settings },
    // { item_type = "image", path = "UI/Buttons/one_side.png", width = 40, height = 40, margin = 8, settings = { rotation = 180 } },
    // { item_type = "text", text = "-- ?? --", width = 72, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/" + config.back_button + ".png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Back", width = 53, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/" + config.select_button + ".png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Start Game", width = 127, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/" + config.prev_filter_button + ".png", width = 80, height = 40, margin = 8 },
    { item_type = "image", path = "UI/Buttons/" + config.next_filter_button + ".png", width = 80, height = 40, margin = 8 },
    { item_type = "text", text = "Change Region", width = 172, height = 40, settings = controls_text_settings },
];

local menu_controls_items = [
    { item_type = "image", path = "UI/Buttons/one_side.png", width = 40, height = 40, margin = 8, settings = { rotation = 180 } },
    { item_type = "text", text = "Game List", width = 112, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/two_sides.png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Select Option", width = 149, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/" + config.back_button + ".png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "Back", width = 53, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/" + config.select_button + ".png", width = 40, height = 40, margin = 8 },
    { item_type = "text", text = "OK", width = 34, height = 40, margin = 44, settings = controls_text_settings },
    { item_type = "image", path = "UI/Buttons/" + config.prev_filter_button + ".png", width = 80, height = 40, margin = 8 },
    { item_type = "image", path = "UI/Buttons/" + config.next_filter_button + ".png", width = 80, height = 40, margin = 8 },
    { item_type = "text", text = "Change Region", width = 172, height = 40, settings = controls_text_settings },
];

local game_list_controls = ControlsInfoPanel(fe.layout.width / 2, 936, anchors.middle.center, game_list_controls_items);
local menu_controls = ControlsInfoPanel(fe.layout.width / 2, 936, anchors.middle.center, menu_controls_items);
menu_controls.set_visible(false);

//Header
local header = fe.add_surface(1920, 136);
header.y = -8;
header.add_image("UI/" + filter_data.platform + "/header.png", 0, -28);
local header_down_animation = Animation(150, header, { properties = { y = { start = -8, end = 0 } }, onstop = function(anim) { top_menu.show_selector(true); }, onstart = function(anim) {
    current_level = levels.menu;
    game_list.show_selector(false);
    top_menu.items[top_menu.selected_item].highlight(true);
} }, true);

local header_up_animation = Animation(150, header, { properties = { y = { start = 0, end = -8 } }, onstop = function(anim) { game_list.show_selector(true); }, onstart = function(anim) {
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
local selector_jump_effect = fe.add_surface(game_list.selector.texture_width, game_list.selector.texture_height);
selector_jump_effect.visible = false;

local selector_jump_effect_content =
{
    left = selector_jump_effect.add_image("UI/white_pixel.png", 0, 0, 8, game_list.selector.texture_height),
    top = selector_jump_effect.add_image("UI/white_pixel.png", 0, 0, game_list.selector.texture_width, 8),
    right = selector_jump_effect.add_image("UI/white_pixel.png", game_list.selector.texture_width, 0, 8, game_list.selector.texture_height),
    bottom = selector_jump_effect.add_image("UI/white_pixel.png", 0, game_list.selector.texture_height, game_list.selector.texture_width, 8)
}
selector_jump_effect_content.right.origin_x = 8;
selector_jump_effect_content.bottom.origin_y = 8;
foreach(side in selector_jump_effect_content) side.set_rgb(54, 255, 254);

local selector_jump_effect_anim = Animation(150, selector_jump_effect, {
    onupdate = function(anim)
    {
        selector_jump_effect_content.left.width = 8 * anim.config.properties.width.start / anim.object.width.tofloat();
        selector_jump_effect_content.top.height = 8 * anim.config.properties.height.start / anim.object.height.tofloat();
        selector_jump_effect_content.right.width = 8 * anim.config.properties.width.start / anim.object.width.tofloat();
        selector_jump_effect_content.right.origin_x = selector_jump_effect_content.right.width;
        selector_jump_effect_content.bottom.height = 8 * anim.config.properties.height.start / anim.object.height.tofloat();
        selector_jump_effect_content.bottom.origin_y = selector_jump_effect_content.bottom.height;
    },
    onstop = function(anim) { anim.object.visible = false; }
    });

function prepare_selector_jump_effect(up, from, to)
{
    selector_jump_effect_anim.setup_properties({
        x = { start = from.x - from.origin_x, end = to.x - to.origin_x },
        y = { start = from.y - from.origin_y + game_list.surface.y, end = to.y - to.origin_y },
        width = { start = from.texture_width, end = to.texture_width },
        height = { start = from.texture_height, end = to.texture_height },
    });
    local begin = up ? "start" : "end";
    selector_jump_effect.x = selector_jump_effect_anim.config.properties.x[begin];
    selector_jump_effect.y = selector_jump_effect_anim.config.properties.y[begin];
    selector_jump_effect.width = selector_jump_effect_anim.config.properties.width[begin];
    selector_jump_effect.height = selector_jump_effect_anim.config.properties.height[begin];
}

function play_selector_jump(up)
{
    prepare_selector_jump_effect(up, game_list.selector, top_menu.selector);
    selector_jump_effect.visible = true;
    selector_jump_effect_anim.config.interpolation = up ? interpolations.linear : interpolations.reverse;
    selector_jump_effect_anim.play();
}


/**********
Fade Effect
**********/
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
            fe.list.index += direction.left;
            game_list.select_next(direction.left);
            miniature_list.select_next(direction.left);
            return true;
        case "right":
            if(blocking_animations_running()) return true;
            fe.list.index += direction.right;
            game_list.select_next(direction.right);
            miniature_list.select_next(direction.right);
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