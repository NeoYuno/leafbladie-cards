--Volcano Golem
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be normal summoned/set
	c:EnableUnsummonable()
	--Must be special summoned by a card effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--return
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.retreg)
	c:RegisterEffect(e3)
	--spsummon or take damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.phcon)
	e4:SetCost(s.phcost)
	e4:SetOperation(s.phop)
	c:RegisterEffect(e4)
	--search or burn
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id, 2))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1, id)
	e5:SetCondition(s.condition)
	e5:SetCost(s.cost)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
end
--Must be special summoned by a card effect
function s.splimit(e, se, sp, st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
--Spsummon
function s.sumfilter(c)
	return c:GetAttack()+c:GetDefense()
end
function s.rescon(sg, e, tp, mg)
	Duel.SetSelectedCard(sg)
	return aux.ChkfMMZ(1)(sg, e, 1-tp, mg) and sg:CheckWithSumGreater(s.sumfilter, 3000)
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local g=Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
	if chk==0 then return aux.SelectUnselectGroup(g, e, tp, 1, #g, s.rescon, 0) end
	local rg=aux.SelectUnselectGroup(g, e, tp, 1, #g, s.rescon, 1, tp, HINTMSG_RELEASE, s.rescon, nil, false)
	Duel.Release(rg, REASON_COST)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e, 0, tp, false, false, 1-tp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, 1-tp, false, false, POS_FACEUP)
	end
end
--return
function s.retreg(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END, 0, 2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_PHASE+PHASE_END, 2)
	Duel.RegisterEffect(e1, tp)
end
function s.retcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnCount()==e:GetLabel() and e:GetOwner():GetFlagEffect(id)~=0
end
function s.retop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetOwner()
	c:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_CONTROL)
	e1:SetValue(c:GetOwner())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
	c:RegisterEffect(e1)
end
--spsummon or take damage
function s.phcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer()==tp
end
function s.phcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.CheckLPCost(tp, 500) end
    Duel.PayLPCost(tp, 500)
end
function s.spfilter(c, e, tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.phop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_GRAVE, 0, nil, e, tp)
	if #g>0 then
		if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local sg=g:Select(tp, 1, 1, nil)
		if #sg>0 then
			Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
		end
	else Duel.Damage(tp, 1000, REASON_EFFECT) end
end
--search or burn
function s.condition(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetOwnerPlayer()
	return e:GetHandler():GetControler()==c
end
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.CheckLPCost(tp, 100) end
	local lp=Duel.GetLP(tp)
	local m=math.floor(math.min(lp, 3000)/100)
	local t={}
	for i=1,m do
		t[i]=i*100
	end
	local ac=Duel.AnnounceNumber(tp, table.unpack(t))
	Duel.PayLPCost(tp, ac)
	e:SetLabel(ac)
end
function s.filter(c, costvalue)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAttack(costvalue) and c:IsAbleToHand()
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local costvalue=e:GetLabel()
	local op=Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
	if op==3 then
		local g=Duel.GetMatchingGroup(s.filter, tp, LOCATION_DECK, 0, nil, costvalue)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil, costvalue)
		if #sg>0 then
			Duel.SendtoHand(sg, nil, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, sg)
		end
	else
		Duel.Damage(1-tp, costvalue, REASON_EFFECT)
	end
end
