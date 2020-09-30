--!strict

--[[
	ContextActionPositioning
	~Lucas W. (codes4breakfast)
	
	Licensed to Mullets_Gavin for use in any projects, solo or in teams.
	Others: please contact me if you want to use this in your projects.
	
	Utility module with functions to calculate CAS-like button positions based
	on configurable parameters.
	
	How to use:
	  This module has two main functions, get_positions and get_positions_with_rows.
	  It is recommended that you use the second function, which returns an array of
	  UDim2 values which you should set your CAS-style buttons's positions to. 
	  For usage examples, refer to the Demonstration LocalScript.
	
	Notes:
	  This module will work with buttons generally on the bottom right corner
	  of the screen (no other corners support ATM - yell at me in one week for
	  that), with certain tolerance. After a certain distance the code starts
	  spitting infinities, so please do not place the button too far from the
	  corner.
	  
	  This module returns positions for buttons with an AnchorPoint equal to
	  0, 0 - make any necessary adjustments if you are using other values.
	
	API:
	  Functions:
		ContextActionPositioning.get_positions(cfg: PositionSettings): PositionResult
		  Given a set of settings (documented below), returns a list of button positions
		  so that they form a ring, paired with the radius of that ring. This radius can
		  be supplied as MIN_RADIUS in subsequent calls for multiple rings to be generated.
		  
		ContextActionPositioning.get_positions_with_rows(buttons_per_ring: List<number>, cfg: PositionSettings): List<UDim2>
		  Given a list of button numbers per ring and button positioning settings (see below),
		  returns a list of button positions so that they form multiple rings - having each ring
		  the number of buttons supplied in the first parameter.
		  
		  For example, a buttons_per_ring = {2, 1, 3} would return the positions
		  of buttons so that they form a ring of two, a ring of one, and a ring
		  of three.
		  
		  It is recommended that you use this function rather than get_positions.
		  If you only want to have one row of buttons, supply a list with one
		  element.
		  
	  Types:
	  	List<T>
	  	  Alias for {[number]: T}, i.e. an array of elements of type T.
	  
		PositionSettings
		  Settings table for the functions. For the sake of performance,
		  any instances of this struct supplied to the functions
		  will be modified - specifically, fields N_BUTTONS and MIN_RADIUS -
		  so do not rely on them staying immutable.
		  	CENTER_BUTTON_POSITION: Vector2
		  		The AbsolutePosition of the bigger button, around
		  		which the other buttons orbit.
		  		
			CENTER_BUTTON_SIZE: Vector2
				The AbsoluteSize of the bigger button.
				
			N_BUTTONS: number
				The number of buttons to be placed in the ring. Does
				not need to be set for get_positions_with_rows.
			
			MIN_RADIUS_PADDING: number
				Extra radius offset, in pixels, from the minimum radius.
			
			BUTTON_PADDING: number
				Space, in pixels, between buttons in the same ring.
				
			BUTTON_SIZE: UDim2
				The ring buttons' size.
				
			RESOLUTION: Vector2
				The resolution of the LayerCollector (such as ScreenGui.AbsoluteSize).
				
			MIN_RADIUS: number?
				Optional. Represents the minimum radius to place the buttons around.
				Used internally in get_positions_with_rows - leave this unset!
		
		PositionResult
		  Results table returned by get_positions.
			list: List<UDim2>
				A list of button positions in a ring.
				
			radius: number
				The radius of the generated ring.
]]

type List<T> = {[number]: T}

export type PositionSettings = {
	CENTER_BUTTON_POSITION: Vector2,
	CENTER_BUTTON_SIZE: Vector2,
	N_BUTTONS: number,
	MIN_RADIUS_PADDING: number,
	BUTTON_PADDING: number,
	BUTTON_SIZE: UDim2,
	RESOLUTION: Vector2,
	MIN_RADIUS: number?,
}

export type PositionResult = {
	list: {[number]: UDim2},
	radius: number
}

local CAP = {}

local function map(x, x0, x1, y0, y1)
	return (x-x0)/(x1-x0)*(y1-y0)+y0
end

function CAP.make_table_on_the_fly(n,max_per_row)
	local t = table.create(math.floor(n/max_per_row), max_per_row)
	if n%max_per_row ~= 0 then
		table.insert(t, n % max_per_row)
	end
	return t
end

function CAP.make_table_on_the_fly_but_bigger_every_time(n)
	local accum = n
	local start_row = 3
	local inc = 1
	local t = {}
	while accum > 0 do
		local row_size = start_row + #t*inc
		if accum >= row_size then
			table.insert(t, row_size)
			accum -= row_size
		else
			table.insert(t, accum)
			accum = 0
		end
	end
	return t
end

function CAP.get_positions(cfg: PositionSettings): PositionResult
	local res = cfg.RESOLUTION
	
	-- get the min radius from the corner of the screen
	local b_pos = cfg.CENTER_BUTTON_POSITION
	local min_radius
	if b_pos.X/res.X > b_pos.Y/res.Y then
		min_radius = res.X - b_pos.X
	else
		min_radius = res.Y - b_pos.Y
	end
	if cfg.MIN_RADIUS then
		min_radius = math.max(min_radius, cfg.MIN_RADIUS)
	end
	
	-- assuming button is a circle
	local approx_angle = (math.pi/2)/(cfg.N_BUTTONS+1)
	local factor = math.sqrt(2 + 2*math.cos(approx_angle))
	local approx_space = factor*0.5*(cfg.BUTTON_SIZE.X.Offset + cfg.BUTTON_SIZE.X.Scale * res.X)
	local min_space = (approx_space + cfg.BUTTON_PADDING) * (cfg.N_BUTTONS + 1)
	local radius = math.max(min_space / (0.5 * math.pi), min_radius + cfg.BUTTON_SIZE.X.Offset + cfg.MIN_RADIUS_PADDING)
	
	-- place the buttons
	local corner = b_pos + cfg.CENTER_BUTTON_SIZE
	local x_offset = res.X - corner.X
	local y_offset = res.Y - corner.Y
	
	-- calculate the extra angle
	local extra_angle_x = math.asin(x_offset/radius)
	local extra_angle_y = math.asin(y_offset/radius)
	local total_angle = math.pi/2 + extra_angle_x + extra_angle_y
	
	local result: PositionResult = {list = {}, radius = radius}
	for i=1, cfg.N_BUTTONS do
		local angle = (math.pi/2)/(cfg.N_BUTTONS+1) * i
		-- idk why its extra_angle_x and then extra_angle_y but it works
		angle = map(angle, 0, math.pi/2, -extra_angle_x, math.pi/2 + extra_angle_y)
		result.list[i] = UDim2.new(0, res.X - x_offset + math.cos(math.pi/2 + angle) * radius, 0, res.Y - y_offset - math.sin(math.pi/2 + angle) * radius)
	end
	
	return result
end

function CAP.get_positions_with_rows(buttons_per_ring: List<number>, cfg: PositionSettings): List<UDim2>
	local result: List<UDim2> = {}
	
	local last_offset = cfg.MIN_RADIUS or 0
	for _, n_buttons in ipairs(buttons_per_ring) do
		cfg.N_BUTTONS = n_buttons
		cfg.MIN_RADIUS = last_offset
		
		local positions = CAP.get_positions(cfg)
		table.move(positions.list, 1, #positions.list, #result+1, result)
		
		last_offset = positions.radius
	end
	
	return result
end

return CAP