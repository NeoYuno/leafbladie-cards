--Venom Garter
local s,id=GetID()
function s.initial_effect(c)
	--Excavate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetType(EFFECT_TYPE_QUICK_O)
	e1x:SetCode(EVENT_FREE_CHAIN)
	e1x:SetHintTiming(0,TIMING_END_PHASE)
	e1x:SetCondition(s.con2)
	c:RegisterEffect(e1x)
    --To deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetType(EFFECT_TYPE_QUICK_O)
	e2x:SetCode(EVENT_FREE_CHAIN)
	e2x:SetHintTiming(0,TIMING_END_PHASE)
	e2x:SetCondition(s.con2)
	c:RegisterEffect(e2x)
end
s.listed_series={0x50}
s.listed_names={54306223}
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsPlayerAffectedByEffect(tp,210243003)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,210243003)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsRace,RACE_REPTILE),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        local ct=g:GetClassCount(Card.GetCode)+3
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return false end
		local dg=Duel.GetDecktopGroup(tp,ct)
		return dg:FilterCount(Card.IsAbleToHand,nil)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsSetCard(0x50)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsRace,RACE_REPTILE),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local ct=g:GetClassCount(Card.GetCode)+3
	Duel.ConfirmDecktop(tp,ct)
	local dg=Duel.GetDecktopGroup(tp,ct)
	if #dg>0 then
		Duel.DisableShuffleCheck()
		if dg:IsExists(s.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=dg:FilterSelect(tp,s.thfilter,1,1,nil)
            if sg:GetFirst():IsAbleToHand() then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
                Duel.ShuffleHand(tp)
                ct=ct-1
            end
            local fc=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,54306223),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            if ct>0 then
                if fc and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                    dg:Sub(sg)
                    Duel.SendtoGrave(dg,REASON_EFFECT)
                else
                    Duel.MoveToDeckBottom(ct,tp)
                    Duel.SortDeckbottom(tp,tp,ct)
                end
            end
        end
    end
end
function s.tdfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 then
		Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct==0 then return end
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			local mg=Duel.GetDecktopGroup(tp,1)
			Duel.MoveSequence(mg:GetFirst(),1)
		end
        Duel.Draw(tp,1,REASON_EFFECT)
	end
end