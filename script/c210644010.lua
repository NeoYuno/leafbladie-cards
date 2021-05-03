--Darker Rule Ha Des
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_FIEND), 2)
    --Actlimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0, 1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
    --Activate 1 of 3 effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
--actlimit
function s.actfilter(c, tp)
	return c and c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return s.actfilter(Duel.GetAttacker(), tp) or s.actfilter(Duel.GetAttackTarget(), tp)
end
--Activate 1 of 3 effects
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 or c:GetFlagEffect(id+1)==0 or c:GetFlagEffect(id+2)==0 end
	local t1=c:GetFlagEffect(id)
	local t2=c:GetFlagEffect(id+1)
    local t3=c:GetFlagEffect(id+2)
	local op=0
	if t1==0 and t2==0 and t3==0 then
		op=Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1), aux.Stringid(id, 2))
	elseif t1==0 then op=Duel.SelectOption(tp, aux.Stringid(id, 0))
    elseif t2==0 then op=Duel.SelectOption(tp, aux.Stringid(id, 1))
	else Duel.SelectOption(tp, aux.Stringid(id, 2)) end
	e:SetLabel(op)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		--Negate the effects of other monsters on the field, except Fiend monsters
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
        e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace, RACE_FIEND)))
		e1:SetReset(RESET_PHASE+PHASE_END, 2)
        c:RegisterEffect(e1)
    elseif e:GetLabel()==1 then
        --Monsters that are banished, as well as monsters in the GY, cannot activate their effects, except Fiend monsters
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(1, 1)
        e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace, RACE_FIEND)))
        e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END, 2)
        c:RegisterEffect(e1)
	else
        --Effects of monsters in the hand cannot be activated, except Fiend monsters
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(1, 1)
        e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace, RACE_FIEND)))
        e1:SetValue(s.aclimit2)
		e1:SetReset(RESET_PHASE+PHASE_END, 2)
        c:RegisterEffect(e1)
	end
end
--Monsters that are banished, as well as monsters in the GY, cannot activate their effects, except Fiend monsters
function s.aclimit(e, re, tp)
    local loc=re:GetActivateLocation()
    return (loc==LOCATION_GRAVE or loc==LOCATION_REMOVED) and re:IsActiveType(TYPE_MONSTER)
end
--Effects of monsters in the hand cannot be activated, except Fiend monsters
function s.aclimit2(e, re, tp)
    local loc=re:GetActivateLocation()
    return loc==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
