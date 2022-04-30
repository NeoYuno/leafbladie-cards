--Papyrus the Underground Cool Guy
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
    --Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.indestg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    --To hand
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
    --Counter
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_BE_BATTLE_TARGET)
    e5:SetCondition(s.ctcon)
	e5:SetTarget(s.cttg)
	e5:SetOperation(s.ctop)
	c:RegisterEffect(e5)
    --Destroy replace
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(s.reptg)
	c:RegisterEffect(e6)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144001}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,210144001),tp,LOCATION_MZONE,0,1,nil)
end

function s.indestg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsCode(210144001)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at and at:IsFaceup() and at:IsRelateToBattle() end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:IsRelateToBattle() and at:IsFaceup() then
		at:AddCounter(COUNTER_LV,7)
    end
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE))
		and c:GetDefense()>=500 end
	if Duel.SelectEffectYesNo(tp,c,96) then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		return true
	else return false end
end