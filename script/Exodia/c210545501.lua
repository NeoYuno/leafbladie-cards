--Ritual of the Ultimate Forbidden Lord
local WIN_REASON_RUFL=0x23
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Win
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetOperation(s.winop)
	c:RegisterEffect(e2)
end
s.listed_names={id,13893596}
s.listed_series={0x40}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
    if chk==0 then return #g>0 end
    Duel.SendtoDeck(g,tp,2,REASON_COST)
end
function s.tgfilter(c)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp)
    return c:IsCode(13893596) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
    local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
    if Duel.SendtoGrave(rg,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
            --Multi-attack
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_ATTACK_ALL)
            e1:SetValue(1)
            tc:RegisterEffect(e1)
        end
    end
end
function s.filter(c)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:GetReasonEffect():GetHandler():IsCode(id,13893596)
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	if g:GetClassCount(Card.GetCode)==5 then
		Duel.Win(tp,WIN_REASON_RUFL)
	end
end