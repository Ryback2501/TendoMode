fe.load_module("wafam/artwork");
fe.load_module("wafam/animate");

//Data

Regions <- {
    Nintendont = {platform = "Nintendont", flag = "" }
    // Famicom_Japan = { platform = "Famicom", flag = "JAP" },
    // NES_USA = { platform = "NES", flag = "USA" },
    // NES_Europe = { platform = "NES", flag = "EUR" },
    // Super_Famicom_Japan = { platform = "Super Famicom", flag = "JAP" }
    // SNES_USA = { platform = "Super NES", flag = "USA" }
    // SNES_Europe = { platform = "Super NES EUR", flag = "EUR" }
}

levels <- {
    menu = 0,
    games = 1
};

direction <- {
    left = -1,
    right = 1,
    up = 2,
    down = -2
};

anchors <- {
    top =    { left = 0, center = 1, right = 2 },
    middle = { left = 3, center = 4, right = 5 },
    bottom = { left = 6, center = 7, right = 8 }
}

// TODO: Move this properties to settings or a table

//Used in position_to_x function
local slot_offset = 120;

//Used in GameSlot class and in position_to_x function
local slot_width = 340;

//Used in GameList class
local max_slot_index = 4;

//Used in GameSlot class
local art_max_width = 304;
local art_max_height = 272;

// TODO: For small flyers
// local mini_art_max_side = 52;

// Classes

class GameList
{
    surface = null;
    game_slots = [];
    selector = null;
    index = 0;

    constructor(x, y, width, height)
    {
        index = fe.list.index;
        surface = fe.add_surface(width, height);
        surface.x = x;
        surface.y = y;

        local size = get_fixed_list_size();
        for(local i = 0; i < size; i++)
        {
            game_slots.append(GameSlot(surface, i, i == index));
            update_position(game_slots[i], -2);
        }
        selector = Selector(surface);
        update_positions(index - 2);
    }

    function select_next(dir)
    {
        if((dir < 0 && selector.slot_index > 0) || (dir > 0 && selector.slot_index < max_slot_index))
        {
            selector.move(dir);
        }
        else
        {
            local from = index - selector.slot_index - 2;
            local to = index - selector.slot_index + max_slot_index + 2;
            update_positions(from);
            for(local i = from; i <= to; i++)
            {
                local index = abs_remainder(i, game_slots.len());
                game_slots[index].move(dir);
            }
        }

        index = abs_remainder(index + dir, game_slots.len());
        fe.list.index = index;
        game_slots[abs_remainder(index - dir, game_slots.len())].highlight(false);
        game_slots[index].highlight(true);
    }

    function get_fixed_list_size() 
    {
        local list_size = fe.filters[fe.list.filter_index].size;
        local min_size = max_slot_index + 5;
        return ((min_size / list_size) + (min_size % list_size == 0 ? 0 : 1)) * list_size;
    }

    function update_positions(first_slot_index)
    {
        for(local i = -2; i <= max_slot_index + 2; i++) update_position(game_slots[abs_remainder(i + first_slot_index + 2, game_slots.len())], i);
    }

    function update_position(game_slot, position)
    {
        local x_pos = position_to_x(position);
        foreach(item in game_slot.items) item.x = x_pos;
    }
}

class GameSlot
{
    index = 0;

    surface = null;

    items = null;
    move_animations = null;
    highlight_animation = null;

    constructor(surface, index, selected = false)
    {
        this.index = index;
        this.surface = surface;

        items = {
            bg = surface.add_image("UI/" + filter_data.platform + "/game_bg.png", 0, 8),
            selected_bg = surface.add_image("UI/" + filter_data.platform + "/selected_game_bg.png", 0, 8),
            art = add_artwork("flyer", surface, index - fe.list.index)
        }

        if(!selected) { items.selected_bg.alpha = 0; }
        fit_aspect_ratio(items.art, art_max_width, art_max_height);
        items.art.origin_x = -(8 +  ((art_max_width - items.art.width) / 2));
        items.art.origin_y = -(16 +  ((art_max_height - items.art.height) / 2));

        move_animations = {};
        foreach(key, value in items) move_animations[key] <- Animation(150, value);
        highlight_animation = Animation(150, items.selected_bg);
    }

    function set_visible(visible = true)
    {
        foreach(item in items) item.visible = visible;
    }

    function move(dir)
    {
        foreach(anim in move_animations)
        {
            anim.setup_properties({ x = { start = anim.object.x, end = anim.object.x - (slot_width * dir) } });
            anim.play();
        }
    }

    function highlight(selected)
    {
        highlight_animation.setup_properties({ alpha = { start = selected ? 0 : 255, end = selected ? 255 : 0 } });
        highlight_animation.play();
    }
}

class Selector
{
    slot_index = 0;
    image = null;
    move_animation = null;

    constructor(surface)
    {
        image = surface.add_image("UI/" + filter_data.platform + "/selector_game.png", position_to_x(0), 8);
        image.origin_x = 8;
        image.origin_y = 8;
        image.zorder = 100;
        move_animation = Animation(150, image, null, true);
    }

    function move(dir)
    {
        slot_index = slot_index + dir;
        move_animation.setup_properties({ x = { start = position_to_x(slot_index - dir), end = position_to_x(slot_index) } })
        move_animation.play();
    }

    function set_visible(visible)
    {
        image.visible = visible;
    }
}

class Menu
{
    items = {};
    selector = null;
    selected_item = 0;
    selector_animation = null;

    constructor(items_info, x, y, item_width, item_height, holder = ::fe)
    {
        for(local i = 0; i < items_info.len(); i++)
        {
            items[i] <- MenuItem(holder, items_info[i], x + (i * item_width), y, item_width, item_height);
        }
        selector = fe.add_image("UI/selector_menu.png");
        selector.origin_x = 8;
        selector.origin_y = 8;
        selector.x = items[selected_item].bg.x;
        selector.y = items[selected_item].bg.y;
        selector.visible = false;
        selector_animation = Animation(150, selector);
    }

    function select_next(dir)
    {
        if((dir < 0 && selected_item > 0) || (dir > 0 && selected_item < items.len() - 1))
        {
            selected_item += dir;
            selector_animation.setup_properties({ x = { start =  items[selected_item - dir].bg.x, end =  items[selected_item].bg.x } });
            items[selected_item - dir].highlight(false);
            items[selected_item].highlight(true);
            selector_animation.play();
        }
    }

    function show_selector(show)
    {
        selector.x = items[selected_item].bg.x;
        selector.visible = show;
    }

    function run_selected_action()
    {
        items[selected_item].action();
    }
}

class MenuItem
{
    icon = null;
    bg = null;
    highlight_animation = null;
    action = null;
    zoom_increment = 6;

    constructor(holder, info, x, y, w, h)
    {
        bg = holder.add_image("UI/white_pixel.png", x, y, w, h);
        set_rgba(bg, 0, 0, 0, 128);

        icon = holder.add_image(info.image);
        icon.width = icon.texture_width;
        icon.height = icon.texture_height;
        icon.origin_x = icon.width / 2;
        icon.origin_y = icon.height / 2;
        icon.x = bg.x + ((w - icon.texture_width) / 2) + icon.origin_x;
        icon.y = bg.y + ((h - icon.texture_height) / 2) + icon.origin_y;

        highlight_animation = Animation(150, icon);
        action = info.action;
    }

    function highlight(selected)
    {
        if(selected) set_rgba(bg, 63, 191, 255, 255);
        else set_rgba(bg, 0, 0, 0, 128);

        local increment = zoom_increment * (selected ? 1 : -1);
        highlight_animation.setup_properties({
            origin_x = { start = icon.origin_x, end = icon.origin_x + (increment / 2) },
            origin_y = { start = icon.origin_y, end = icon.origin_y + (increment / 2) },
            width = { start = icon.width, end = icon.texture_width + increment },
            height = { start = icon.height, end = icon.texture_height + increment }
        });
        highlight_animation.play();
    }
}

class Panel
{
    surface = null;

    constructor(x, y, anchor, items_data)
    {
        local total_w = 0;
        local max_h = 0;
        foreach(item in items_data)
        {
            total_w += get_item_total_width(item);
            if(max_h < item.height) max_h = item.height;
        }

        surface = fe.add_surface(total_w, max_h);
        surface.x = x;
        surface.y = y;
        surface.origin_x = (surface.width / 2) * (anchor % 3);
        surface.origin_y = (surface.height / 2) * (anchor / 3);

        local obj = null;
        total_w = 0;
        foreach(item in items_data)
        {
            switch(item.item_type)
            {
                case "image":
                    obj = surface.add_image(item.path, total_w, (max_h - item.height) / 2);
                    obj.origin_x = obj.texture_width / 2;
                    obj.origin_y = obj.texture_height / 2;
                    obj.x += obj.origin_x;
                    obj.y += obj.origin_y;
                    break;
                case "text":
                    obj = surface.add_text(item.text, total_w, (max_h - item.height) / 2, item.width, item.height);
                    obj.set_rgb(167, 0, 0);
                    break;
                default:
                    ::print("Type " + item.item_type + " not supported.\n");
            }
            if("settings" in item) foreach(key, value in item.settings) obj[key] = value;
            total_w += get_item_total_width(item);
        }
    }

    function set_visible(visible)
    {
        surface.visible = visible;
    }

    function get_item_total_width(item)
    {
        return item.width + ("margin" in item ? item.margin : 0);
    }
}

// Functions

function abs_remainder(a, b)
{
    return (a < 0 ? a % b + b : a) % b;
}

// TODO: Add to class and propagate??
function position_to_x(position)
{
    return slot_offset + (slot_width * position);
}

function set_rgba(obj, r, g, b, a)
{
    obj.set_rgb(r, g, b);
    obj.alpha = a;
}

function get_filter_data()
{
    if(Regions.rawin(fe.filters[fe.list.filter_index].name))
    {
        return Regions[fe.filters[fe.list.filter_index].name];
    }
    return Regions["Nintendont"];
}