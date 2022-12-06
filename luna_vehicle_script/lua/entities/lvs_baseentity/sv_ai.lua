
function ENT:OnCreateAI()
end

function ENT:OnRemoveAI()
end

function ENT:OnToggleAI( name, old, new)
	if new == old then return end
	
	if new == true then
		local Driver = self:GetDriver()
		
		if IsValid( Driver ) then
			Driver:ExitVehicle()
		end

		self:OnCreateAI()
	else
		self:OnRemoveAI()
	end
end

function ENT:AITargetInFront( ent, range )
	if not IsValid( ent ) then return false end
	if not range then range = 45 end
	
	local DirToTarget = (ent:GetPos() - self:GetPos()):GetNormalized()
	
	local InFront = math.deg( math.acos( math.Clamp( self:GetForward():Dot( DirToTarget ) ,-1,1) ) ) < range

	return InFront
end

function ENT:AICanSee( otherEnt )
	if not IsValid( otherEnt ) then return false end

	local trace = {
		start = self:LocalToWorld( self:OBBCenter() ),
		endpos = otherEnt:LocalToWorld( otherEnt:OBBCenter() ),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = self:GetCrosshairFilterEnts(),
	}

	return util.TraceHull( trace ).Entity == otherEnt
end

function ENT:AIGetTarget()
	if (self._lvsNextAICheck or 0) > CurTime() then return self._LastAITarget end

	self._lvsNextAICheck = CurTime() + 1
	
	local MyPos = self:GetPos()
	local MyTeam = self:GetAITEAM()

	if MyTeam == 0 then self._LastAITarget = NULL return NULL end

	local ClosestTarget = NULL
	local TargetDistance = 60000

	for _, veh in pairs( LVS:GetVehicles() ) do
		if veh == self then continue end

		local Dist = (veh:GetPos() - MyPos):Length()

		if Dist > TargetDistance or not self:AITargetInFront( veh, 100 ) then continue end

		local HisTeam = veh:GetAITEAM()

		if HisTeam == 0 then continue end

		if HisTeam == self:GetAITEAM() then
			if HisTeam ~= 3 then continue end
		end

		if self:AICanSee( veh ) then
			ClosestTarget = veh
			TargetDistance = Dist
		end
	end

	self._LastAITarget = ClosestTarget
	
	return ClosestTarget
end

