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

const fetterData = {
  '【嫌悪】':    {effect:'敵対認識', text:'失敗した攻撃は全て（射程内にいるなら）\n嫌悪の対象に命中。箇所は被害側任意決定'},
  '【独占】':    {effect:'独占衝動', text:'戦闘開始と戦闘終了時に１つずつ、\n対象はパーツを１つ選んで損傷する。'},
  '【依存】':    {effect:'幼児退行', text:'最大行動値-2'},
  '【執着】':    {effect:'追尾監視', text:'戦闘開始と戦闘終了時に１点ずつ、\n対象はあなたへの未練に狂気点を加える。'},
  '【恋心】':    {effect:'自傷行動', text:'戦闘開始と戦闘終了時に１つずつ、\nあなたはパーツ１つを選んで損傷する。'},
  '【対抗】':    {effect:'過剰競争', text:'戦闘開始と戦闘終了時に１つずつ、あなたは\n任意の未練に狂気点を１点追加で得る。'},
  '【友情】':    {effect:'共鳴依存', text:'損傷共有：数（カウント＝対象）\nセッション終了時に計算。'},
  '【保護】':    {effect:'常時密着', text:'阻害：移動以外【別エリア＝対象】\n制限：移動対象【自身＆対象以外】'},
  '【憧憬】':    {effect:'贋作妄想', text:'阻害：移動以外【同エリア＝対象】\n制限：移動対象【自身＆対象以外】'},
  '【信頼】':    {effect:'疑心暗鬼', text:'あなた以外の全ての姉妹の最大行動値-1'},
  '【恐怖】':    {effect:'認識拒否', text:'あらゆる行動判定・狂気判定の出目-1'},
  '【隷属】':    {effect:'造反有理', text:'戦闘中、あなたが失敗した攻撃判定は\n全て、大失敗として扱う。'},
  '【不安】':    {effect:'挙動不審', text:'最大行動値-2'},
  '【燐憫】':    {effect:'過剰移入', text:'「サヴァント」に対する攻撃判定の出目-1'},
  '【愛憎】':    {effect:'凶愛心中', text:'狂気判定・攻撃判定で大成功する毎に\n[判定値-10]個の自身のパーツを損傷させる'},
  '【悔恨】':    {effect:'自業自棄', text:'戦闘中、あなたが失敗した攻撃判定は全て、\nあなた自身の任意の個所にダメージを与える'},
  '【軽蔑】':    {effect:'眼中不在', text:'戦闘中、同エリアの手駒が\nあなたに対して行う攻撃判定の出目+1'},
  '【憤怒】':    {effect:'激情暴走', text:'行動判定・狂気判定の出目-1'},
  '【怨念】':    {effect:'不倶戴天', text:'戦闘中、あなたは、逃走判定ができない。\nまた、あなたが「自身と未練の対象」以外を対象にしたマニューバを使用する際、\n行動値１点を追加で減らさなくてはいけない。'},
  '【憎悪】':    {effect:'痕跡破壊', text:'【タイミング：この未練が発狂した際】\nあなた以外の姉妹１人は任意P２つを損傷'},
  '【忌避】_中立':{effect:'隔絶意識', text:'阻害：移動以外【同エリア＝対象＆サヴァント】\n制限：移動対象【自身＆対象＆サヴァント以外】'},
  '【嫉妬】_中立':{effect:'不協和音', text:'全ての姉妹は行動判定に修正-1'},
  '【依存】_中立':{effect:'幼児退行', text:'最大行動値-2'},
  '【燐憫】_中立':{effect:'過剰移入', text:'「サヴァント」に対する攻撃判定の出目-1'},
  '【感謝】_中立':{effect:'病的返礼', text:'この未練が発狂した際、任意の基本P２つ\n（なければ最もLvの低い強化P１つ）を損傷'},
  '【悔恨】_中立':{effect:'自業自棄', text:'戦闘中、あなたが失敗した攻撃判定は全て、\nあなた自身の任意の個所にダメージを与える'},
  '【期待】_中立':{effect:'希望転結', text:'あなたは狂気点を追加して振り直しを行う際、\n出目-1（この効果は累積する）。'},
  '【保護】_中立':{effect:'生前回帰', text:'あなたは「レギオン」を\nマニューバの対象に選べない。'},
  '【尊敬】_中立':{effect:'神化崇拝', text:'あなたは「他の姉妹」を\nマニューバの対象に選べない。'},
  '【信頼】_中立':{effect:'疑心暗鬼', text:'あなた以外の全ての姉妹の最大行動値-1'}
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

// 未練欄 ----------------------------------------
function setFetter(num){
  const note = form['fetterNote'+num].value;
  const data = fetterData[note];
  if(data){
    form['fetterEffect'+num].value = data.effect;
    form['fetterEffectNote'+num].value = data.text;
  }
}

window.addEventListener('load', () => {
  for(let i=1;i<=6;i++){
    const select = form['fetterNote'+i];
    if(!select) continue;
    Object.keys(fetterData).forEach(name => {
      const op = document.createElement('option');
      op.value = name;
      op.textContent = name;
      select.appendChild(op);
    });
    if(select.dataset.value){ select.value = select.dataset.value; }
    setFetter(i);
  }
});
