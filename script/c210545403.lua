--Protector Priest Shimon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion materials
    Fusion.AddProcMix(c, true, true, aux.FilterBoolFunctionEx(Card.IsRace, RACE_SPELLCASTER), aux.FilterBoolFunction(Card.IsAttackBelow, 1000))
    --Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1, id)
	e2:SetCost(s.setcost)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Alternate synchro summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.sprcon)
	--e3:SetTarget(s.sprtg)
	e3:SetOperation(s.sprop)
	e3:SetValue(SUMMON_TYPE_SYNCHRO)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_EXTRA, 0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
s.listed_names={64043465}
s.listed_series={0x40}
--Special summon
function s.spfilter(c, tp, sc)
	return c:IsSetCard(0x40) and Duel.GetLocationCountFromEx(tp, tp, c, sc)>0
end
function s.spcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp, s.spfilter, 1, false, 1, true, c, tp, nil, nil, nil, tp, c)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
	local g=Duel.SelectReleaseGroup(tp, s.spfilter, 1, 1, false, true, true, c, tp, nil, false, nil, tp, c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g, REASON_COST+REASON_MATERIAL)
	g:DeleteGroup()
end
--Set
function s.cfilter(c, tp)
	if not (c:IsSetCard(0x40) and c:IsAbleToGraveAsCost()) then return false end
	if not c:IsLocation(LOCATION_SZONE) then
		return Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil)
	else
		return c:IsFaceup() and Duel.GetLocationCount(tp, LOCATION_SZONE)>-1 
			and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil, true)
	end
end
function s.filter(c)
	return c:IsCode(64043465) and c:IsSSetable()
end
function s.setcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, nil, tp)
	Duel.SendtoGrave(g, REASON_COST)
end
function s.setop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g>0 then
		Duel.SSet(tp, g:GetFirst())
	end
end
--Alternate synchro summon
function s.eftg(e, c)
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.filter1, tp, LOCATION_MZONE, 0, nil)
	local tuner=mg:GetFirst()
	local rg=Duel.GetMatchingGroup(s.filter2, tp, 0xff, 0, tuner)
	return c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil, mg+rg)
end
function s.rescon(tuner, c)
	return	function(sg, e, tp, mg)
				sg:AddCard(tuner)
				local res=Duel.GetLocationCountFromEx(tp, tp, sg, c)>0 
					and sg:CheckWithSumEqual(Card.GetLevel, c:GetLevel(), #sg, #sg)
					and sg:GetClassCount(function(c) return c:GetLocation()&~(LOCATION_MZONE) end)==2
				sg:RemoveCard(tuner)
				return res
			end
end
function s.filter1(c)
	return c:IsCode(id) and c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost()
end
function s.filter2(c)
	return (c:IsFaceup() and c:HasLevel() and not c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost() and c:IsLocation(LOCATION_MZONE))
	    or (c:HasLevel() and c:IsSetCard(0x40) and c:IsAbleToGraveAsCost() and c:IsLocation(LOCATION_DECK))

end
function s.sprcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.filter1, tp, LOCATION_MZONE, 0, nil)
	local tuner=g:GetFirst()
	local rg=Duel.GetMatchingGroup(s.filter2, tp, 0xff, 0, tuner)
	return #g>0 and aux.SelectUnselectGroup(rg, e, tp, nil, nil, s.rescon(tuner, c), 0)
end
function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
	local pg=aux.GetMustBeMaterialGroup(tp, Group.CreateGroup(), tp, nil, nil, REASON_SYNCHRO)
	if #pg>0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SMATERIAL)
	local g=Duel.SelectMatchingCard(tp, s.filter1, tp, LOCATION_MZONE, 0, 1, 1, nil)
	local tuner=g:GetFirst()
	local rg=Duel.GetMatchingGroup(s.filter2, tp, 0xff, 0, tuner)
	if #g>0 and #rg>0 then
		local sg=aux.SelectUnselectGroup(rg, e, tp, nil, nil, s.rescon(tuner, c), 1, tp, HINTMSG_SMATERIAL, s.rescon(tuner, c), s.rescon(tuner, c))
		if #sg>0 then
			sg:AddCard(tuner)
			Duel.SendtoGrave(sg, REASON_COST+REASON_MATERIAL+REASON_SYNCHRO)
		end
	end
end