local json = require("json")

local function keys(obj)
  if obj == nil then
    return nil
  end
  local keys = {}
  for key, _ in pairs(obj) do
    table.insert(keys, key)
  end
  if next(keys) == nil then
    return nil
  else
    return keys
  end
end

local data = nil
local need_translation = nil

commands.add_command("dump_recipes", nil, function(command)

  if data ~= nil then
    game.player.print('previous dump_recipes command still running')
  end

  data = {}
  need_translation = {}

  script.on_event(defines.events.on_string_translated, function(event)
    if need_translation[event.id] == nil then
      return
    end
    if event.translated then
      need_translation[event.id].translated_name = event.result
    end
    need_translation[event.id] = nil
    if next(need_translation) == nil then
      --helpers.write_file('recipes.data', serpent.block(data))
      helpers.write_file('recipes.json', json.stringify(data))
      game.print('output written to script-output/recipes.json')
      script.on_event(defines.events.on_string_translated, nil)
      data = nil
      need_translation = nil
    end
  end)

  data['game_version'] = '2.0'

  data['groups'] = {}
  local add_group = function(group)
    if not data['groups'][group.name] then
      data['groups'][group.name] = {
        name = group.name,
	type = group.type,
	order = group.order,
      }
      if group.type == 'item-group' then
        data['groups'][group.name]['order_in_recipe'] = group.order_in_recipe
      end
    end
    return group.name
  end
  data['quality'] = {}
  for _, v in pairs(prototypes.quality) do
    data['quality'][v.name] = {
      name = v.name,
      level = v.level,
      next_probability = v.next_probability,
      beacon_power_usage_multiplier = v.beacon_power_usage_multiplier,
      mining_drill_resource_drain_multiplier = v.mining_drill_resource_drain_multiplier,
      group = add_group(v.group),
      subgroup = add_group(v.subgroup),
    }
    if v.next then
      data['quality'][v.name]['next'] = v.next.name
    end
    local id = game.player.request_translation(v.localised_name)
    need_translation[id] = data['quality'][v.name]
  end
  data['quality_names'] = {}
  do
    local i = 1
    local name = 'normal'
    repeat
      data['quality_names'][i] = name
      name = data['quality'][name].next
      i = i + 1
    until name == nil
  end
  data['recipes'] = {}
  for _, v in pairs(game.player.force.recipes) do
    data['recipes'][v.name] = {
      name = v.name,
      category = v.category,
      ingredients = v.ingredients,
      products = v.products,
      main_product = v.prototype.main_product,
      allowed_effects = v.prototype.allowed_effects,
      maximum_productivity = v.prototype.maximum_productivity,
      energy = v.energy,
      order = v.order,
      group = add_group(v.group),
      subgroup = add_group(v.subgroup),
      enabled = v.enabled,
      productivity_bonus = v.productivity_bonus,
    }
    local id = game.player.request_translation(v.localised_name)
    need_translation[id] = data['recipes'][v.name]
  end
  data['items'] = {}
  for _, v in pairs(prototypes.item) do
    data['items'][v.name] = {
      name = v.name,
      type = v.type,
      order = v.order,
      group = add_group(v.group),
      subgroup = add_group(v.subgroup),
      stack_size = v.stack_size,
      weight = v.weight,
      fuel_category = v.fuel_category,
      fuel_value = v.fuel_value,
      module_effects = v.module_effects,
      rocket_launch_products = v.rocket_launch_products,
      --spoil_result = v.spoil_result,
      --plant_result = v.plant_result,
      flags = keys(v.flags),
    }
    local id = game.player.request_translation(v.localised_name)
    need_translation[id] = data['items'][v.name]
  end
  data['fluids'] = {}
  for _, v in pairs(prototypes.fluid) do
    data['fluids'][v.name] = {
      name = v.name,
      order = v.order,
      group = add_group(v.group),
      subgroup = add_group(v.subgroup),
      fuel_value = v.fuel_value,
    }
    local id = game.player.request_translation(v.localised_name)
    need_translation[id] = data['fluids'][v.name]
  end
  data['entities'] = {}
  for _, v in pairs(prototypes.entity) do
    local name = v.name
    local type = v.type
    if (type == "beacon"
         or type == "furnace"
         or type == "assembling-machine"
         or type == "crafting-machine"
         or type == "boiler"
         or type == "rocket-silo"
         --or type == "rocket-silo-rocket"
         or type == "beacon")
    then
      local energy_consumption = nil
      local drain = nil
      local pollution = nil
      local energy_source = nil
      local fuel_categories = nil
      if v.electric_energy_source_prototype and v.energy_usage ~= nil then
        energy_consumption = v.energy_usage * 60
	drain = v.electric_energy_source_prototype.drain * 60
        --pollution = v.electric_energy_source_prototype.emissions * energy_consumption * 60
        energy_source = 'electric'
      elseif v.burner_prototype and v.energy_usage ~= nil then
  	energy_consumption = v.energy_usage * 60
	drain = 0
        --pollution = v.burner_prototype.emissions * energy_consumption * 60
        energy_source = 'burner'
        fuel_categories = keys(v.burner_prototype.fuel_categories)
      end
      entity_info = {
	name = name,
	type = type,
	order = v.order,
	group = v.group.name,
	subgroup = v.subgroup.name,
	crafting_speed = {},
	crafting_categories = keys(v.crafting_categories),
	allowed_effects = keys(v.allowed_effects),
	module_inventory_size = v.module_inventory_size,
        fixed_recipe = v.fixed_recipe,
	effect_receiver = v.effect_receiver,
        
	rocket_parts_required = v.rocket_parts_required,
	--rocket_rising_delay = v.rocket_rising_delay,
	--launch_wait_time = v.launch_wait_time,
        --light_blinking_speed = v.light_blinking_speed,
        --door_opening_speed = v.door_opening_speed,
        --rising_speed = v.rising_speed,
        --engine_starting_speed = v.engine_starting_speed,
        --flying_speed = v.flying_speed,
        
	distribution_effectivity = v.distribution_effectivity,
	distribution_effectivity_bonus_per_quality_level = v.distribution_effectivity_bonus_per_quality_level,
	supply_area_distance = {},
	energy_consumption = energy_consumption,
	drain = drain,
        energy_source = energy_source,
        fuel_categories = fuel_categories,
	--pollution = pollution,
        width = v.tile_width,
        height = v.tile_height,
        flags = keys(v.flags),
      }
      for _, name  in pairs(data['quality_names'])  do
        entity_info['crafting_speed'][name] = v.get_crafting_speed(name)
	entity_info['supply_area_distance'][name] = v.get_supply_area_distance(name)
      end
      if not next(entity_info['crafting_speed']) then
        entity_info['crafting_speed'] = nil
      end
      if not next(entity_info['supply_area_distance']) then
        entity_info['supply_area_distance'] = nil
      end
      data['entities'][v.name] = entity_info
      local id = game.player.request_translation(v.localised_name)
      need_translation[id] = data['entities'][v.name]
    end
  end
end)

