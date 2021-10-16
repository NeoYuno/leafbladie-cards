--Blasting Vein
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xb9}
function s.filter(c,e)
	return c:IsFacedown() and c:IsDestructable(e) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,0,1,e:GetHandler(),e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_SZONE,0,1,1,e:GetHandler(),e)
	Duel.Destroy(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,0xb9)
	if Duel.Draw(p,d,REASON_EFFECT)>0 and #g>0 then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end