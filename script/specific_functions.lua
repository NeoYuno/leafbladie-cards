--
function Auxiliary.HermosEquipLimit(tc,te)
	return function(e,c)
		if c~=tc then return false end
		local effs={e:GetHandler():GetCardEffect(210183820+EFFECT_EQUIP_LIMIT)}
		for _,eff in ipairs(effs) do
			if eff==te then return true end
		end
		return false
	end
end
--
function Auxiliary.EquipAndLimitRegister(c,e,tp,tc,code,previousPos)
	if not Duel.Equip(tp,c,tc,previousPos==nil and true or previousPos) then return false end
	--Add Equip limit
	if code then
		tc:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD,0,0)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(Auxiliary.HermosEquipLimit(tc,e:GetLabelObject()))
	c:RegisterEffect(e1)
	return true
end
--
function Auxiliary.AddHermosEquipLimit(c,con,equipval,equipop,linkedeff,prop,resetflag,resetcount)
	local finalprop=prop and prop|EFFECT_FLAG_CANNOT_DISABLE or EFFECT_FLAG_CANNOT_DISABLE
	local e1=Effect.CreateEffect(c)
	if con then
		e1:SetCondition(con)
	end
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(finalprop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e1:SetCode(210183820)
	e1:SetLabelObject(linkedeff)
	if resetflag and resetcount then
		e1:SetReset(resetflag,resetcount)
	elseif resetflag then
		e1:SetReset(resetflag)
	end
	e1:SetValue(function(tc,c,tp) return equipval(tc,c,tp) end)
	e1:SetOperation(function(c,e,tp,tc) equipop(c,e,tp,tc) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(finalprop&~EFFECT_FLAG_CANNOT_DISABLE,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e2:SetCode(210183820+EFFECT_EQUIP_LIMIT)
	if resetflag and resetcount then
		e2:SetReset(resetflag,resetcount)
	elseif resetflag then
		e2:SetReset(resetflag)
	end
	c:RegisterEffect(e2)
	linkedeff:SetLabelObject(e2)
end