fe.load_module("wafam/artwork");
fe.load_module("wafam/animate");

//Data

Regions <- {
    Nintendont = {platform = "Nintendont", flag = "" },
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

// Classes

class GameList
{
    surface = null;
    game_slots = [];
    selector = null;
    selector_move_anim = null;

    index = 0;
    selector_position = 0;
    max_position = 0;
    slot_width = 0;
    slot_offset = 0;

    constructor(x, y, width, height, slot_width, slot_offset, art_max_width, art_max_height)
    {
        max_position = (((width - slot_offset) / slot_width) - 1).tointeger();
        local size = get_fixed_list_size();
        if(size == 0) return;

        index = fe.list.index;
        surface = fe.add_surface(width, height);
        surface.x = x;
        surface.y = y;

        this.slot_width = slot_width;
        this.slot_offset = slot_offset;

        for(local i = 0; i < size; i++)
        {
            game_slots.append(GameSlot(surface, i, art_max_width, art_max_height, i == index));
            game_slots[i].set_position(position_to_x(-2));
        }
        update_game_slot_positions(index - 2);

        selector = surface.add_image("UI/" + filter_data.platform + "/selector_game.png", position_to_x(0), 8);
        selector.origin_x = 8;
        selector.origin_y = 8;
        selector_move_anim = Animation(150, selector, null, true);
    }

    function select_next(dir)
    {
        if((dir == direction.left && selector_position > 0) || (dir == direction.right && selector_position < max_position))
        {
            move_selector(dir);
        }
        else
        {
            local from = index - selector_position - 2;
            local to = index - selector_position + max_position + 2;
            update_game_slot_positions(from);
            for(local i = from; i <= to; i++)
            {
                local ind = abs_remainder(i, game_slots.len());
                game_slots[ind].move(dir, slot_width);
            }
        }

        index = abs_remainder(index + dir, game_slots.len());
        game_slots[abs_remainder(index - dir, game_slots.len())].highlight(false);
        game_slots[index].highlight(true);
    }

    function get_fixed_list_size() 
    {
        local list_size = fe.filters[fe.list.filter_index].size;
        if(list_size == 0) return list_size;

        local min_size = max_position + 5;
        return ((min_size / list_size) + (min_size % list_size == 0 ? 0 : 1)) * list_size;
    }

    function update_game_slot_positions(first_slot_index)
    {
        for(local i = -2; i <= max_position + 2; i++)
            game_slots[abs_remainder(i + first_slot_index + 2, game_slots.len())].set_position(position_to_x(i));
    }

    function position_to_x(position)
    {
        return (slot_width * position) + slot_offset;
    }

    function move_selector(dir)
    {
        selector_position += dir;
        selector_move_anim.setup_properties({ x = { start = position_to_x(selector_position - dir), end = position_to_x(selector_position) } })
        selector_move_anim.play();
    }

    function show_selector(visible)
    {
        selector.visible = visible;
    }
}

class GameSlot
{
    index = 0;
    surface = null;
    items = null;
    move_animations = null;
    highlight_animation = null;

    constructor(surface, index, art_max_width, art_max_height, selected = false)
    {
        this.surface = surface;
        this.index = index;
        local players_data = get_players_data();
        if(players_data.len() == 0) players_data.append("1");
        
        items = {
            bg = surface.add_image("UI/" + filter_data.platform + "/game_bg.png", 0, 8),
            selected_bg = surface.add_image("UI/" + filter_data.platform + "/selected_game_bg.png", 0, 8),
            art = add_artwork("flyer", surface, index - fe.list.index),
            players = surface.add_image("UI/" + players_data[0] + "P.png", 0, 8)
        }
        
        if(!selected) items.selected_bg.alpha = 0;
        fit_aspect_ratio(items.art, art_max_width, art_max_height);
        items.art.origin_x = -(8 +  ((art_max_width - items.art.width) / 2));
        items.art.origin_y = -(16 +  ((art_max_height - items.art.height) / 2));
        items.players.origin_x = -232;
        items.players.origin_y = -300;
        if(players_data.len() > 1 && players_data[1] == "s") items.players.set_rgb(255, 160, 64);

        move_animations = {};
        foreach(key, value in items) move_animations[key] <- Animation(150, value);
        highlight_animation = Animation(150, items.selected_bg);
    }

    function set_visible(visible = true)
    {
        foreach(item in items) item.visible = visible;
    }

    function set_position(position)
    {
        foreach(item in items) item.x = position;
    }

    function move(dir, distance)
    {
        foreach(anim in move_animations)
        {
            anim.setup_properties({ x = { start = anim.object.x, end = anim.object.x - (distance * dir) } });
            anim.play();
        }
    }

    function highlight(selected)
    {
        highlight_animation.setup_properties({ alpha = { start = selected ? 0 : 255, end = selected ? 255 : 0 } });
        highlight_animation.play();
    }
    
    function get_players_data()
    {
        return split(fe.game_info(Info.Players, index - fe.list.index), ",");
    }
}

class Menu
{
    items = null;
    selector = null;
    selected_item = 0;
    selector_animation = null;

    constructor(items_info, x, y, item_width, item_height, holder = ::fe)
    {
        items = {};
        for(local i = 0; i < items_info.len(); i++)
            items[i] <- MenuItem(holder, items_info[i], x + (i * item_width), y, item_width, item_height);

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
        if((dir == direction.left && selected_item > 0) || (dir == direction.right && selected_item < items.len() - 1))
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

class MiniatureList
{
    surface = null;
    miniatures = null;
    selector = null;
    center_pos_x = 0;
    visible_slots = 0;
    slots_margin = 0;

    constructor(center_x, y, side, selector_distance, visible_miniatures, margin)
    {
        local len = fe.filters[fe.list.filter_index].size;
        if(len == 0) return;
        
        miniatures = [];
        center_pos_x = center_x;
        visible_slots = visible_miniatures < len ? visible_miniatures : len;
        slots_margin = margin;
        surface = fe.add_surface((side * visible_slots) + ((visible_slots - 1) * 4), side + selector_distance)
        surface.y = y;

        for(local i = 0; i < len; i++)
        {
            miniatures.append(add_artwork("flyer", surface, i - fe.list.index));
            fit_aspect_ratio(miniatures[i], side, side);
            miniatures[i].y = side + selector_distance - miniatures[i].height;
        }

        place_miniatures();

        selector = AnimatedSprite(surface.add_image("UI/selector_miniature.png"),
            { sprite_width = 40, sprite_height = 24, animations = { selector = { sequence = [0, 1, 2, 1], fps = 12, loop = true } } });
        selector.sprite.origin_x = selector.sprite.subimg_width / 2;
        selector.sprite.origin_y = selector.sprite.subimg_height + 4;
        selector.play();

        select_next();
    }

    function select_next(dir = null)
    {
        place_miniatures(dir);
        select_current_miniature();
    }

    function place_miniatures(dir = null)
    {
        if(visible_slots == miniatures.len() && dir != null) return;
        local first = null;

        if(dir == null)
            first = visible_slots == miniatures.len() || fe.list.index < visible_slots - slots_margin ? 0 : fe.list.index - visible_slots + slots_margin + 1;
        else
        {
            local limit = fe.list.index + (dir * slots_margin);
            if( !miniatures[fe.list.index].visible)
                first = dir == direction.right ? 0 : miniatures.len() - visible_slots;
            else if (limit >= 0 && limit < miniatures.len() && !miniatures[limit].visible)
                first = limit + (dir == direction.right ? (1 - visible_slots) : 0);
        }

        if(first == null) return;

        local total_x = 0;
        for(local i = 0; i < miniatures.len(); i++)
        {
            miniatures[i].visible = i >= first && i < first + visible_slots;
            if(miniatures[i].visible)
            {
                miniatures[i].x = total_x;
                total_x += miniatures[i].width + 4;
            }
        }
        surface.x = center_pos_x - ((total_x - 4) / 2);
    }

    function select_current_miniature()
    {
        selector.sprite.x = (miniatures[fe.list.index].x + miniatures[fe.list.index].width / 2).tointeger();
        selector.sprite.y = miniatures[fe.list.index].y;
    }
}

class ControlsInfoPanel
{
    surface = null;
    items = null;

    constructor(center_x, y, items_data, holder = ::fe)
    {
        items = [];
        local total_w = 0;
        local max_h = 0;
        foreach(item in items_data)
        {
            total_w += get_item_total_width(item);
            if(max_h < item.height) max_h = item.height;
        }

        local obj = null;
        local total_x = 0;
        local pos_x = 0;
        local pos_y = 0;
        foreach(item in items_data)
        {
            pos_x = center_x + total_x - (total_w / 2);
            pos_y = y + ((max_h - item.height) / 2);

            switch(item.item_type)
            {
                case "image":
                    obj = holder.add_image(item.path, pos_x, pos_y);
                    obj.origin_x = obj.texture_width / 2;
                    obj.origin_y = obj.texture_height / 2;
                    obj.x += obj.origin_x;
                    obj.y += obj.origin_y;
                    break;
                case "text":
                    obj = holder.add_text(item.text, pos_x, pos_y, item.width, item.height);
                    obj.set_rgb(167, 0, 0);
                    break;
            }

            if("settings" in item) foreach(key, value in item.settings) obj[key] = value;
            items.append(obj);
            total_x += get_item_total_width(item);
        }
    }

    function set_visible(visible)
    {
        foreach(item in items) item.visible = visible; 
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

function set_rgba(obj, r, g, b, a)
{
    obj.set_rgb(r, g, b);
    obj.alpha = a;
}

function get_filter_data()
{
    if(Regions.rawin(fe.filters[fe.list.filter_index].name))
        return Regions[fe.filters[fe.list.filter_index].name];
    return Regions[config.default_region];
}