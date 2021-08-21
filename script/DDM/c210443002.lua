--Immortal Yaranzo
local s,id=GetID()
function s.initial_effect(c)
	--To grave
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --To hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.roll_dice=true
function s.tgfilter(c)
    return c.roll_dice and c:IsAbleToGraveAsCost()
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,3,nil)
    local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,3,nil)
	if chk==0 then return (b1 and Duel.IsEnvironment(210443010)) or b2 end
    if b1 and Duel.IsEnvironment(210443010) then
        if b2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,3,3,nil)
            if #g>0 then
                Duel.SendtoGrave(g,REASON_COST)
            end
        elseif not b2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,3,3,nil)
            if #g>0 then
                Duel.SendtoGrave(g,REASON_COST)
            end
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,3,3,nil)
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_COST)
        end
    end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.thfilter(c)
	return c.roll_dice and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	local dc=Duel.TossDice(tp,1)
	Duel.ConfirmDecktop(tp,dc)
	local dg=Duel.GetDecktopGroup(tp,dc)
	local g=dg:Filter(s.thfilter,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	dc=dc-1
	if dc>0 then
		Duel.MoveToDeckBottom(dc,tp)
		Duel.SortDeckbottom(tp,tp,dc)
	end
end