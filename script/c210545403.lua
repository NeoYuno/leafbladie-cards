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
	--Synchro summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, id)
	e3:SetTarget(s.syntg)
	e3:SetOperation(s.synop)
	c:RegisterEffect(e3)
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
--Synchro summon
function s.mgfilter(c)
	return c:IsLocation(LOCATION_DECK) and c:IsSetCard(0x40)
end
function s.mgfilter1(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and not c:IsType(TYPE_TUNER) and c:GetLevel()~=0
end
function s.spfilter1(c, e, tp, lv)
	return Duel.GetLocationCountFromEx(tp, tp, sg, c) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end
function s.rescon(sg, e, tp, mg)
	local lv=sg:GetSum(Card.GetOriginalLevel)+e:GetHandler():GetOriginalLevel()
	return sg:FilterCount(Card.IsLocation, nil, LOCATION_DECK)<=1
		and Duel.IsExistingMatchingCard(s.spfilter1, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, lv)
end
function s.syntg(e, tp, eg, ep, ev, re, r, rp, chk)
	local mg=Duel.GetMatchingGroup(s.mgfilter, tp, LOCATION_DECK, 0, nil)
	if chk==0 then return aux.SelectUnselectGroup(mg, e, tp, 1, 1, s.rescon, 0) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end
function s.spfilter2(c, e, tp, lv)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end
function s.synop(e, tp, eg, ep, ev, re, r, rp)
	local mg=Duel.GetMatchingGroup(s.mgfilter, tp, LOCATION_DECK, 0, nil)
	local mg2=Duel.GetMatchingGroup(s.mgfilter1, tp, LOCATION_MZONE, 0, nil)
	if aux.SelectUnselectGroup(mg, e, tp, 1, 1, s.rescon, 0) then
		local sg=aux.SelectUnselectGroup(mg, e, tp, 1, 1, s.rescon, 1, tp, HINTMSG_TOGRAVE)
		sg:AddCard(e:GetHandler())
		if aux.SelectUnselectGroup(mg2, e, tp, 1, 1, s.rescon, 0) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		    local sg2=aux.SelectUnselectGroup(mg2, e, tp, nil, nil, s.rescon, 1, tp, HINTMSG_TOGRAVE)
			sg2:Merge(sg)
			if Duel.SendtoGrave(sg2, REASON_EFFECT)>0 then
				local syg=sg2:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
				local lv=syg:GetSum(Card.GetOriginalLevel)
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local ssg=Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, lv)
				local sc=ssg:GetFirst()
				if sc then
					Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
					sc:CompleteProcedure()
				end
			end
		elseif Duel.SendtoGrave(sg, REASON_EFFECT)>0 then
			local syg=sg:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
			local lv=syg:GetSum(Card.GetOriginalLevel)
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
			local ssg=Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, lv)
			local sc=ssg:GetFirst()
			if sc then
				Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
				sc:CompleteProcedure()
			end
		end
	end
end