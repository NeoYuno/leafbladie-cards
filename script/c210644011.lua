--Masquerade (Custom)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x583)
    c:RegisterEffect(e0)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.filter1(c)
    return c:GetEquipGroup():IsExists(Card.IsMask,1,nil) and c:IsControlerCanBeChanged()
end
function s.columnfilter(c)
    return c:IsMask() and c:IsType(TYPE_CONTINUOUS)
end
function s.filter2(c)
    return c:GetColumnGroup():IsExists(s.columnfilter,1,nil,tp) and c:IsControlerCanBeChanged()
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and (s.filter1(chkc) or s.filter2(chkc))
	end
	local b1=Duel.IsExistingTarget(s.filter1, tp, 0, LOCATION_MZONE, 1, nil)
	local b2=Duel.IsExistingTarget(s.filter2, tp, 0, LOCATION_MZONE, 1, nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
	elseif b1 then
		op=Duel.SelectOption(tp, aux.Stringid(id, 0))
	else
		op=Duel.SelectOption(tp, aux.Stringid(id, 1))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_CONTROL)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
		local g=Duel.SelectTarget(tp, s.filter1, tp, 0, LOCATION_MZONE, 1, 1, nil)
		Duel.SetOperationInfo(0, CATEGORY_CONTROL, g, 1, 0, 0)
	else
		e:SetCategory(CATEGORY_CONTROL)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
		local g=Duel.SelectTarget(tp, s.filter2, tp, 0, LOCATION_MZONE, 1, 1, nil)
		Duel.SetOperationInfo(0, CATEGORY_CONTROL, g, 1, 0, 0)
	end
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)
	if e:GetLabel()==0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and Duel.GetControl(tc, tp) then
			local c=e:GetOwner()
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_CONTROL)
			e1:SetValue(tc:GetOwner())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.retcon1)
			tc:RegisterEffect(e1)
		end
	else
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and Duel.GetControl(tc, tp) then
			local c=e:GetOwner()
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_CONTROL)
			e1:SetValue(tc:GetOwner())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.retcon2)
			tc:RegisterEffect(e1)
		end
	end
end
function s.retcon1(e)
	local c=e:GetHandler()
	return not c:GetEquipGroup():IsExists(Card.IsMask, 1, nil)
end
function s.retcon2(e)
	local c=e:GetHandler()
	return not c:GetColumnGroup():IsExists(Card.IsMask, 1, nil)
end