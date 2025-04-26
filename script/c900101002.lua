--アティプスの蟲惑魔
--Traptrix Atypus
--Scripted by Hatter
--Editted by N10K
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ monsters, including a Plant or Insect monster
	Xyz.AddProcedure(c,nil,4,3,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--Unaffected by trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--"Traptrix" monsters gain 1000 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_TRAPTRIX))
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	--Negate effects of face-up cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_TRAPTRIX}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_TRAPTRIX,lc,SUMMON_TYPE_XYZ,tp) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_INSECT|RACE_PLANT,lc,sumtype,tp)
end
function s.efilter(e,te)
	return te:IsTrapEffect()
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(s.ntfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsNegatable() end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_INSECT|RACE_PLANT),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,POS_FACEDOWN,REASON_EFFECT)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #g==0 then return end
	local neg_chk=false
	local c=e:GetHandler()
	for tc in g:Iter() do
		if tc:IsCanBeDisabledByEffect(e) then neg_chk=true end
		--Negate effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	if not neg_chk then return end
	local rg=Duel.GetMatchingGroup(aux.AND(s.ntfilter,Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	if #rg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local srg=rg:Select(tp,1,1,nil)
	if #srg==0 then return end
	Duel.BreakEffect()
	if Duel.Remove(srg,POS_FACEUP,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=g:Select(tp,1,1,nil)
	if #dg>0 then
		Duel.HintSelection(dg,true)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
