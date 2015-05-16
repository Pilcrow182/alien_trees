local alien_trees = {}

-- this is the actual tree-making function
alien_trees.grow_tree = function(pos, trunk, leaves, fruit)
	local height = 5
	for i=0,height-1 do minetest.set_node({x = pos.x, y = pos.y + i, z = pos.z}, {name = trunk}) end
	for j=2,height do
		for k=-2,2 do
			for l=-2,2 do
				local limit = 4
				local testpos = {x = pos.x + k, y = pos.y + j, z = pos.z + l}
				if math.random(0,4) > 0 and math.abs(k)+math.abs(l) < limit then
					local oldnode = minetest.get_node(testpos)
					if oldnode and oldnode.name == "air" then
						local leaf_or_fruit = leaves
						if math.random(0,7) == 3 then leaf_or_fruit = fruit end
						minetest.set_node({x = pos.x + k, y = pos.y + j, z = pos.z + l}, {name = leaf_or_fruit})
					end
				end
			end
		end
	end
end

-- this grows saplings into trees. interval and chance should be much higher than they are here.
minetest.register_abm({
	nodenames = {"alien_trees:sapling"},
	interval = 5, -- this means it checks every 5 seconds, to see if the sapling should grow
	chance = 2, -- this means every time it checks, there is a 1/2 (50%) chance it will grow
	action = function(pos)
		alien_trees.grow_tree(pos, "alien_trees:tree", "alien_trees:leaves", "alien_trees:fruit")
	end
})

-- this makes trees get generated when new chunks load. they grow on normal dirt_with_grass.
minetest.register_on_generated(function(minp, maxp, blockseed)
	if math.random(1, 100) > 99 then return end -- 99% chance tree will spawn.
	local tmp = {x=(maxp.x-minp.x)/2+minp.x, y=(maxp.y-minp.y)/2+minp.y, z=(maxp.z-minp.z)/2+minp.z}
	local pos = minetest.find_node_near(tmp, maxp.x-minp.x, {"default:dirt_with_grass"})
	if pos ~= nil then
		alien_trees.grow_tree(pos, "alien_trees:tree", "alien_trees:leaves", "alien_trees:fruit")
	end
end)

-- this is just a helper-function, to make registering new tree types easier
local clone_item = function(name, newname, newdef)
	local fulldef = {}
	local olddef = minetest.registered_items[name]
	if not olddef then return false end
	for k,v in pairs(olddef) do fulldef[k]=v end
	for k,v in pairs(newdef) do fulldef[k]=v end
	minetest.register_item(":"..newname, fulldef)
end

-- these four sections register some new tree nodes (using the helper-function above)
clone_item("default:sapling", "alien_trees:sapling", {
	description = "Alien sapling",
	tiles = {"alien_trees_sapling.png"},
	inventory_image = "alien_trees_sapling.png",
	wield_image = "alien_trees_sapling.png",
})

clone_item("default:tree", "alien_trees:tree", {
	description = "Alien tree",
	tiles = {"alien_trees_tree_top.png", "alien_trees_tree_top.png", "alien_trees_tree.png"},
})

clone_item("default:apple", "alien_trees:fruit", {
	description = "Alien fruit",
	tiles = {"alien_trees_fruit.png"},
	on_use = minetest.item_eat(-2),
})

clone_item("default:leaves", "alien_trees:leaves", {
	description = "Alien leaves",
	tiles = {"alien_trees_leaves.png"},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'alien_trees:sapling'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'alien_trees:leaves'},
			}
		}
	},
})
