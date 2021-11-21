--Gun Cannon Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{handler=c,fusfilter=s.ffilter,extraop=s.extraop,stage2=s.stage2,matfilter=s.matfil,extrafil=s.fextra,extratg=s.extratg}
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
end
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
end
function s.matfil(c,e,tp,chk)
	return c:IsDestructable(e) and not c:IsImmuneToEffect(e)
end
function s.fcheck(tp,sg,fc)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=#g
end
function s.fextra(e,tp,mg)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g>0 then
		local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c.toss_coin
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
function s.extraop(e,tc,tp,sg)
	local res=Duel.Destroy(sg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)==#sg
	sg:Clear()
	return res
end
function s.stage2(e,tc,tp,sg,chk)
    local c=e:GetHandler()
	if chk==1 then
		--Cannot be negated
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3308)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_DISEFFECT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(s.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
        --Cannot special summon
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(id,0))
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e3:SetTargetRange(1,0)
        e3:SetTarget(s.splimit)
        e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
	end
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end
function s.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK))
end