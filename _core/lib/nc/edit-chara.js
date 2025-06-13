"use strict";
const gameSystem = 'nc';
const form = document.forms.sheet || document.forms[0];
const classBonus = {
  'ステーシー':     {arms:1, mutate:1, modify:0},
  'タナトス':      {arms:1, mutate:0, modify:1},
  'ゴシック':      {arms:0, mutate:1, modify:1},
  'レクイエム':    {arms:2, mutate:0, modify:0},
  'バロック':      {arms:0, mutate:2, modify:0},
  'ロマネスク':    {arms:0, mutate:0, modify:2},
  'サイケデリック':{arms:0, mutate:0, modify:1}
};
function calcEnhance(){
  let arms=0, mutate=0, modify=0;
  let main={arms:0,mutate:0,modify:0};
  let sub ={arms:0,mutate:0,modify:0};
  const mainB = classBonus[form.mainClass.value];
  if(mainB){ main=mainB; arms+=mainB.arms; mutate+=mainB.mutate; modify+=mainB.modify; }
  const subB  = classBonus[form.subClass.value];
  if(subB){ sub=subB; arms+=subB.arms; mutate+=subB.mutate; modify+=subB.modify; }
  document.getElementById('main-class-arms').textContent   = (main.arms   !== undefined ? main.arms   : '');
  document.getElementById('main-class-mutate').textContent = (main.mutate !== undefined ? main.mutate : '');
  document.getElementById('main-class-modify').textContent = (main.modify !== undefined ? main.modify : '');
  document.getElementById('sub-class-arms').textContent    = (sub.arms    !== undefined ? sub.arms    : '');
  document.getElementById('sub-class-mutate').textContent  = (sub.mutate  !== undefined ? sub.mutate  : '');
  document.getElementById('sub-class-modify').textContent  = (sub.modify  !== undefined ? sub.modify  : '');
  const any = form.enhanceAny.value;
  if(any==='arms'){ arms++; }
  else if(any==='mutate'){ mutate++; }
  else if(any==='modify'){ modify++; }
  form.enhanceArms.value = arms;
  form.enhanceMutate.value = mutate;
  form.enhanceModify.value = modify;
  document.getElementById('enhance-arms-base').value = arms;
  document.getElementById('enhance-mutate-base').value = mutate;
  document.getElementById('enhance-modify-base').value = modify;

  const armsGrow   = Number(form.enhanceArmsGrow.value)   || 0;
  const mutateGrow = Number(form.enhanceMutateGrow.value) || 0;
  const modifyGrow = Number(form.enhanceModifyGrow.value) || 0;
  document.getElementById('enhance-arms-total').textContent   = arms   + armsGrow;
  document.getElementById('enhance-mutate-total').textContent = mutate + mutateGrow;
  document.getElementById('enhance-modify-total').textContent = modify + modifyGrow;
}
window.onload = function() {
  calcEnhance();
  ['change','input'].forEach(ev => {
    form.mainClass.addEventListener(ev,calcEnhance);
    form.subClass.addEventListener(ev,calcEnhance);
  });
  document.querySelectorAll('input[name="enhanceAny"]').forEach(r=>{
    ['change','input'].forEach(ev => r.addEventListener(ev,calcEnhance));
  });
  ['enhanceArmsGrow','enhanceMutateGrow','enhanceModifyGrow'].forEach(name=>{
    form[name].addEventListener('input',calcEnhance);
  });
  imagePosition(1);
  setSortable('maneuver','#maneuver-table tbody','tr');
  if(!document.querySelector('#maneuver-list tr')){
    const num = Number(form.maneuverNum.value) || 0;
    for(let i=0; i<num; i++){ addManeuver(); }
  }
  setSortable('memory','#memory-table tbody','tr');
  if(!document.querySelector('#memory-list tr')){
    const num = Number(form.memoryNum.value) || 0;
    for(let i=0; i<num; i++){ addMemory(); }
  }
};

// マニューバ欄 ----------------------------------------
function addManeuver(){
  document.querySelector('#maneuver-table tbody').append(createRow('maneuver','maneuverNum'));
}
function delManeuver(){
  delRow('maneuverNum', '#maneuver-table tbody:last-of-type');
}

// 記憶のカケラ欄 ----------------------------------------
function addMemory(){
  document.querySelector('#memory-table tbody').append(createRow('memory','memoryNum',6));
}
function delMemory(){
  delRow('memoryNum', '#memory-table tbody:last-of-type',2);
}
