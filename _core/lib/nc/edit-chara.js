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
  [form.mainClass.value, form.subClass.value].forEach(cls=>{
    const b = classBonus[cls];
    if(b){ arms+=b.arms; mutate+=b.mutate; modify+=b.modify; }
  });
  const any = form.enhanceAny.value;
  if(any==='arms'){ arms++; }
  else if(any==='mutate'){ mutate++; }
  else if(any==='modify'){ modify++; }
  form.enhanceArms.value = arms;
  form.enhanceMutate.value = mutate;
  form.enhanceModify.value = modify;
}
window.addEventListener('DOMContentLoaded',()=>{
  calcEnhance();
  form.mainClass.addEventListener('change',calcEnhance);
  form.subClass.addEventListener('change',calcEnhance);
  document.querySelectorAll('input[name="enhanceAny"]').forEach(r=>{
    r.addEventListener('change',calcEnhance);
  });
});
