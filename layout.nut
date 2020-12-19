/*******
Settings
*******/
class UserConfig </ help="Settings" /> {
	</ label="Default region", help="The region to show if there is no filter with a mathcing name.", order=1 />
	default_region = "Nintendont";
	</ label="Extra Info Icon", help="Icon of extra information of the game.", options="none,genre,region", order=2 />
	extra_info_icon = "none";
	</ label="Select Button", help="Select button to show for Select action.", options="a,b,x,y,l,l_wide,r,r_wide,select,start,symbol_x,symbol_circle,symbol_square,symbol_triangle", order=3 />
	select_button = "a";
	</ label="Cancel Button", help="Select button to show for Back action.", options="a,b,x,y,l,l_wide,r,r_wide,select,start,symbol_x,symbol_circle,symbol_square,symbol_triangle", order=4 />
	back_button = "b";
	</ label="Previous Filter Button", help="Select button to show for Previous Filter action.", options="a,b,x,y,l,l_wide,r,r_wide,select,start,symbol_x,symbol_circle,symbol_square,symbol_triangle", order=5 />
	prev_filter_button = "r_wide";
	</ label="Next filter Button", help="Select button to show for Next Filter action.", options="a,b,x,y,l,l_wide,r,r_wide,select,start,symbol_x,symbol_circle,symbol_square,symbol_triangle", order=6 />
	next_filter_button = "l_wide";
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
if("background" in settings)
{
    if("color" in settings.background)
    {
        local bg = fe.add_image("UI/white_pixel.png", 0, 128, 1920, 832);
        bg.set_rgb(settings.background.color.r, settings.background.color.g, settings.background.color.b);
    }
    if("image" in settings.background)
    {
        fe.add_image("UI/" + filter_data.platform + "/" + settings.background.image.file, 0, 128);
    }
}

//Title
local game_title = fe.add_surface(1368, 72);
game_title.x = 276;
game_title.y = 200;
game_title.add_image("UI/" + filter_data.platform + "/game_title_bg.png");
local game_title_text = game_title.add_text("[Title]", 0, 0, 1368, 60);
game_title_text.set_rgb(settings.title.color.r, settings.title.color.g, settings.title.color.b);

//Game List
game_list <- GameList(0, 296);

//Miniature list
local miniature_list = MiniatureList(fe.layout.width / 2, 700);

//Controls information
local game_list_controls_items = [
    { item_type = "image", path = "side_up.png" },
    { item_type = "label", text = "Menu", width = 59 },
    { item_type = "image", path = "side_down.png" },
    { item_type = "label", text = "Game Info", width = 114 },
    { item_type = "image", path = "side_left_right.png" },
    { item_type = "label", text = "Select Game", width = 142 },
    { item_type = "image", path = config.back_button + ".png" },
    { item_type = "label", text = "Back", width = 53 },
    { item_type = "image", path = config.select_button + ".png" },
    { item_type = "label", text = "Start Game", width = 127 },
    { item_type = "image", path = config.prev_filter_button + ".png" },
    { item_type = "image", path = config.next_filter_button + ".png" },
    { item_type = "label", text = "Change Region", width = 172 }
];

local menu_controls_items = [
    { item_type = "image", path = "side_down.png" },
    { item_type = "label", text = "Game List", width = 112 },
    { item_type = "image", path = "side_left_right.png" },
    { item_type = "label", text = "Select Option", width = 149 },
    { item_type = "image", path = config.back_button + ".png" },
    { item_type = "label", text = "Back", width = 53 },
    { item_type = "image", path = config.select_button + ".png" },
    { item_type = "label", text = "OK", width = 34 },
    { item_type = "image", path = config.prev_filter_button + ".png" },
    { item_type = "image", path = config.next_filter_button + ".png" },
    { item_type = "label", text = "Change Region", width = 172 }
];

local game_list_controls = ControlsInfoPanel(fe.layout.width / 2, 888, game_list_controls_items);
local menu_controls = ControlsInfoPanel(fe.layout.width / 2, 888, menu_controls_items);
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
menu_options[0] <- { image = "UI/Menu/menu_opt_display.png", action = function() { ::print("Option 1\n"); } };
menu_options[1] <- { image = "UI/Menu/menu_opt_settings.png", action = function() { ::print("Option 2\n"); } };
menu_options[2] <- { image = "UI/Menu/menu_opt_language.png", action = function() { ::print("Option 3\n"); } };
menu_options[3] <- { image = "UI/Menu/menu_opt_legal.png", action = function() { ::print("Option 4\n"); } };
menu_options[4] <- { image = "UI/Menu/menu_opt_help.png", action = function() { ::print("Option 5\n"); } };

top_menu <- Menu(menu_options, 640, 44, 128, 92, header);

local region_flag = header.add_image("UI/Flags/" + filter_data.flag + ".png", 1360, 88);
region_flag.origin_x = region_flag.texture_width / 2;
region_flag.origin_y = region_flag.texture_height / 2;

//Footer
local footer = fe.add_image("UI/" + filter_data.platform + "/footer.png", 0, 960);

/*******************
Selector jump effect
*******************/
local selector_jump_effect;
local selector_jump_effect_anim;
if(fe.filters[fe.list.filter_index].size > 0)
{
    selector_jump_effect = fe.add_surface(game_list.selector.texture_width, game_list.selector.texture_height);
    selector_jump_effect.visible = false;

    local selector_jump_effect_content =
    {
        left = selector_jump_effect.add_image("UI/white_pixel.png", 0, 0, 8, game_list.selector.texture_height),
        top = selector_jump_effect.add_image("UI/white_pixel.png", 0, 0, game_list.selector.texture_width, 8),
        right = selector_jump_effect.add_image("UI/white_pixel.png", game_list.selector.texture_width, 0, 8, game_list.selector.texture_height),
        bottom = selector_jump_effect.add_image("UI/white_pixel.png", 0, game_list.selector.texture_height, game_list.selector.texture_width, 8)
    };
    selector_jump_effect_content.right.origin_x = 8;
    selector_jump_effect_content.bottom.origin_y = 8;
    foreach(side in selector_jump_effect_content) side.set_rgb(54, 255, 254);

    selector_jump_effect_anim = Animation(150, selector_jump_effect, {
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
}

function prepare_selector_jump_effect(up, from, to)
{
    if(selector_jump_effect == null || selector_jump_effect_anim == null)
    {
        return;
    }

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
        case levels.info:
            if(info_signal_overrides(sig)) return true;
            break;
    }
    return global_overrides(sig);
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
        case "down":
            header_up_animation.play();
            play_selector_jump(false);
            menu_controls.set_visible(false);
            game_list_controls.set_visible(true);
            return true;
    }
    return false;
}

function games_signal_overrides(sig)
{
    switch(sig)
    {
        case "left":
            if(blocking_animations_running() || game_list.game_slots.len() == 0) return true;
            fe.list.index += direction.left;
            game_list.select_next(direction.left);
            miniature_list.select_next(direction.left);
            return true;
        case "right":
            if(blocking_animations_running() || game_list.game_slots.len() == 0) return true;
            fe.list.index += direction.right;
            game_list.select_next(direction.right);
            miniature_list.select_next(direction.right);
            return true;
        case "up":
            if(blocking_animations_running() || game_list.game_slots.len() == 0) return true;
            header_down_animation.play();
            play_selector_jump(true);
            game_list_controls.set_visible(false);
            menu_controls.set_visible(true);
            return true;
    }
    return false;
}

function info_signal_overrides(sig)
{
    switch(sig)
    {
        case "left":
        case "right":
        case "down":
        case "prev_filter":
        case "next_filter":
            return true;
        case "up":
        case "back":
            //Go back to game lists
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