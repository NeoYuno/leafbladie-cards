--Dark Scorpion Triple Cross
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
    e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={76922029}
s.listed_series={0x1a}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x1a),tp,0,LOCATION_MZONE,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP) then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.limit)
		tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
        e2:SetTarget(s.limit)
        e2:SetValue(aux.tgoval)
        tc:RegisterEffect(e2)
        local e3=Effect.CreateEffect(c)
        e3:SetCategory(CATEGORY_CONTROL)
        e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e3:SetCode(EVENT_TO_GRAVE)
        e3:SetCondition(s.condition)
        e3:SetTarget(s.target)
        e3:SetOperation(s.operation)
        tc:RegisterEffect(e3)
	end
end
function s.limit(e,c)
	return c:IsFaceup() and c:IsCode(76922029) or (c:IsSetCard(0x1a) and c:IsType(TYPE_MONSTER))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return c:IsPreviousControler(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tg,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
        Duel.GetControl(tg,1-tp)
    end
end