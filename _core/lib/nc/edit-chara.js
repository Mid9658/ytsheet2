"use strict";
const gameSystem = 'nc';
// NOTE: 'form' is provided by the common edit.js
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
  if(typeof imagePosition === 'function'){ imagePosition(1); }
  if(typeof setSortable === 'function'){
    setSortable('memory','#memory-table tbody','tr');
  }
  if(!document.querySelector('#maneuver-list tr')){
    const num = Math.max(Number(form.maneuverNum.value) || 0, 1);
    for(let i=0; i<num; i++){ addManeuver(); }
  }
  if(!document.querySelector('#memory-list tr')){
    const num = Math.max(Number(form.memoryNum.value) || 0, 1);
    for(let i=0; i<num; i++){ addMemory(); }
  }
};

// マニューバ欄 ----------------------------------------
function addManeuver(){
  document.querySelector('#maneuver-table tbody').append(createRow('maneuver','maneuverNum'));
}
function delManeuver(){
  delRow('maneuverNum', '#maneuver-list tr:last-of-type');
}

// ソート
(() => {
  let sortable = Sortable.create(document.getElementById('maneuver-list'), {
    group: "maneuver",
    dataIdAttr: 'id',
    animation: 150,
    handle: '.handle',
    filter: 'thead,tfoot,template',
    onSort: () => { maneuverSortAfter(); },
    onStart: () => {
      document.querySelectorAll('.trash-box').forEach(obj => { obj.style.display = 'none' });
      document.getElementById('maneuver-trash').style.display = 'block';
    },
    onEnd: () => {
      if(!maneuverTrashNum){ document.getElementById('maneuver-trash').style.display = 'none'; }
    },
  });

  let trashtable = Sortable.create(document.getElementById('maneuver-trash-table'), {
    group: "maneuver",
    dataIdAttr: 'id',
    animation: 150,
    filter: 'thead,tfoot,template',
  });

  let maneuverTrashNum = 0;
  function maneuverSortAfter(){
    let num = 1;
    for(let id of sortable.toArray()){
      const row = document.querySelector(`tr#${id}`);
      if(!row) continue;
      replaceSortedNames(row,num,/^(maneuver)(?:Trash)?[0-9]+(.+)$/);
      num++;
    }
    form.maneuverNum.value = num-1;
    let del = 0;
    for(let id of trashtable.toArray()){
      const row = document.querySelector(`tr#${id}`);
      if(!row) continue;
      del++;
      replaceSortedNames(row,'Trash'+del,/^(maneuver)(?:Trash)?[0-9]+(.+)$/);
    }
    maneuverTrashNum = del;
    if(!del){ document.getElementById('maneuver-trash').style.display = 'none'; }
  }
})();

// 記憶のカケラ欄 ----------------------------------------
function addMemory(){
  document.querySelector('#memory-table tbody').append(createRow('memory','memoryNum',6));
}
function delMemory(){
  delRow('memoryNum', '#memory-list tr:last-of-type',2);
}
