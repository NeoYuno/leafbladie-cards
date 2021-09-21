--Slime of Apophis
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xf100,0x21,0,3000,4,RACE_AQUA,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xf100,0x21,0,3000,4,RACE_AQUA,ATTRIBUTE_WATER) then return end
	c:AddMonsterAttribute(TYPE_TRAP+TYPE_EFFECT)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
    --Cannot target with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.limit)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	if Duel.SpecialSummonComplete()==1 and Duel.GetCurrentPhase()>=PHASE_BATTLE_START 
	  and Duel.GetCurrentPhase()<=PHASE_BATTLE then
        --Must attack
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_MUST_ATTACK)
        e2:SetRange(LOCATION_MZONE)
        e2:SetTargetRange(0,LOCATION_MZONE)
        e2:SetReset(RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
        local e3=e2:Clone()
        e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
        e3:SetValue(s.atklimit)
        c:RegisterEffect(e3)
    end
end
function s.atklimit(e,c)
	return c==e:GetHandler()
end
function s.limit(e,c)
	return c:GetCode()~=e:GetHandler():GetCode()
end