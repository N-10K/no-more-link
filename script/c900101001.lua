--クラリアの蟲惑魔
--Traptrix Cularia
--Logical Nonsense
--Editted by N10K
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,4,2,nil,nil,nil,nil,false,s.xyzcheck)
	--Unaffected by trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Set 1 activated "Hole" Normal Trap instead of sending it to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.setcon)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Detach 1 material; special summon 1 level Traptrix monster from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.Detach(1))
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_HOLE,SET_TRAP_HOLE,SET_TRAPTRIX}
function s.xyzfilter(c,xyz,tp)
	return c:IsRace(RACE_INSECT|RACE_PLANT,xyz,SUMMON_TYPE_XYZ,tp)
end
function s.xyzcheck(g,tp,xyz)
	return mg:IsExists(s.xyzfilter,1,nil,xyz,tp)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==tp and re:IsTrapEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE) and not Duel.HasFlagEffect(tp,id)) then return false end
	local rc=re:GetHandler()
	return rc:IsNormalTrap() and rc:IsSetCard({SET_HOLE,SET_TRAP_HOLE}) and rc:IsCanTurnSet() and rc:IsRelateToEffect(re)
		and rc:IsLocation(LOCATION_STZONE)
end
function s.imcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
	--Unaffected by trap effects
function s.efilter(e,te)
	return te:IsTrapEffect()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		local rc=re:GetHandler()
		rc:CancelToGrave()
		Duel.ChangePosition(rc,POS_FACEDOWN)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_TRAPTRIX) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
