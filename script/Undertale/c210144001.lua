-- Frisk the Human
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_LV,LOCATION_MZONE)
	c:SetCounterLimit(COUNTER_LV,19)
  --special summon itself
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_GRAVE)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --Cannot be tributed
  local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_ALL)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
  --spsummon limit
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
  e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e4:SetTargetRange(1,0)
  e4:SetTarget(s.sumlimit)
  c:RegisterEffect(e4)
  --Immune to Monster
 local e5=Effect.CreateEffect(c)
 e5:SetType(EFFECT_TYPE_SINGLE)
 e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
 e5:SetRange(LOCATION_MZONE)
 e5:SetCode(EFFECT_IMMUNE_EFFECT)
 e5:SetValue(s.efilter)
 c:RegisterEffect(e5)
 --Can Self Attacks
 local e6=Effect.CreateEffect(c)
 e6:SetType(EFFECT_TYPE_FIELD)
 e6:SetRange(LOCATION_MZONE)
 e6:SetCode(EFFECT_SELF_ATTACK)
 e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
 e6:SetTargetRange(1,0)
 c:RegisterEffect(e6)
 --place counter
 local e7=Effect.CreateEffect(c)
 e7:SetDescription(aux.Stringid(id,0))
 e7:SetCategory(CATEGORY_COUNTER)
 e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
 e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
 e7:SetCode(EVENT_BATTLE_DESTROYING)
 e7:SetCondition(s.coucon)
 e7:SetTarget(s.coutg)
 e7:SetOperation(s.couop)
 c:RegisterEffect(e7)
 --atk gain
 local e8=Effect.CreateEffect(c)
 e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
 e8:SetType(EFFECT_TYPE_SINGLE)
 e8:SetCode(EFFECT_UPDATE_ATTACK)
 e8:SetValue(s.aduv)
 e8:SetRange(LOCATION_MZONE)
 c:RegisterEffect(e8)
 --SS Chara
 local e9=Effect.CreateEffect(c)
 e9:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
 e9:SetType(EFFECT_TYPE_IGNITION)
 e9:SetRange(LOCATION_MZONE)
 e9:SetCondition(s.sscon)
 e9:SetTarget(s.sstg)
 e9:SetOperation(s.ssop)
 c:RegisterEffect(e9)
 --change Def
 local e10=Effect.CreateEffect(c)
 e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
 e10:SetDescription(aux.Stringid(id,1))
 e10:SetCode(EVENT_PHASE+PHASE_END)
 e10:SetRange(LOCATION_MZONE)
 e10:SetCountLimit(1)
 e10:SetCondition(s.defcon)
 e10:SetTarget(s.deftg)
 e10:SetOperation(s.defop)
 c:RegisterEffect(e10)
end
--Part of "the Underground" archetype
s.counter_place_list={COUNTER_LV}
s.listed_names={210144025} --Chara
--special summon self funktion
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
 if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
--special summon self OP
function s.spop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
 if c:IsRelateToEffect(e) then
  Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
 end
end
--no SS except Underground
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xf4a)
end
--uneffected by opponent monsters
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end
--This card destroyes something by battle
function s.coucon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
--This card less then 19 LV
function s.coutg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(COUNTER_LV)<19 end
end
--Place 1-9 counters
function s.couop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:GetCounter(COUNTER_LV)<19) then return end
	local ct=(19-c:GetCounter(COUNTER_LV))
	if ct==0 then return end
	if ct>9 then ct=9 end
	local t={}
	for i=1,ct do t[i]=i end
	Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	c:AddCounter(COUNTER_LV,ac)
end
-- ATK Value
function s.aduv(e,c)
	return 200*c:GetCounter(COUNTER_LV)
end
-- Chara
function s.sscon(e,tp)
	return e:GetHandler():GetCounter(COUNTER_LV) >= 19
end
--Filter Chara
function s.ssfilter(c,e,tp)
	return c:IsCode(210144025) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return	Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Banish self
	if c:IsRelateToEffect(e) and Duel.Remove(c,LOCATION_MZONE,REASON_EFFECT)>0 then
		-- Special Summon Chara
		if not Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.defcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
