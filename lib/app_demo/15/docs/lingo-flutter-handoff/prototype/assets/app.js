(() => {
'use strict';
const app=document.querySelector('#app');
const params=new URLSearchParams(location.search);
const wall=params.has('wall');
if(wall)document.body.classList.add('wall');

/* ---------------------------------------------------------------- icons */
const icons={
 check:'<path d="m5 12 4.5 4.5L19 7" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/>',
 close:'<path d="m6 6 12 12M18 6 6 18" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"/>',
 arrow:'<path d="M4 12h15m-6-6 6 6-6 6" fill="none" stroke="currentColor" stroke-width="2.7" stroke-linecap="round" stroke-linejoin="round"/>',
 back:'<path d="m14 5-7 7 7 7" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>',
 play:'<path d="M7 4.5c0-1 1-1.5 2-.9l12 7.2c.9.5.9 1.9 0 2.4L9 20.4c-1 .6-2 .1-2-.9Z" fill="currentColor"/>',
 heart:'<path d="M12 21S2 15.7 2 8.5C2 3 8.4 1.4 12 6c3.6-4.6 10-3 10 2.5C22 15.7 12 21 12 21Z" fill="#f47861" stroke="#242522" stroke-width="2.1"/>',
 flame:'<path d="M13 1c2 6-2 7-1 10 2-.3 3-2 3-4 4 4 6 7 5 10-.7 4-4 6-8 6S4 20 4 16C4 10 11 8 13 1Z" fill="#f47861" stroke="#242522" stroke-width="2.1"/><path d="M12 12c1 3-3 4-2 6 .5 2 3.5 2.6 4.5.2C16 16 13 14 12 12Z" fill="#ffd83d"/>',
 bolt:'<path d="m14 2-9 12h6l-1 8 10-13h-7Z" fill="#ffd83d" stroke="currentColor" stroke-width="2.1" stroke-linejoin="round"/>',
 star:'<path d="m12 2 3.1 6.4 7 .9-5 5 .9 7-6-3.3L6 21l.9-6.7L2 9.3l6.9-.9Z" fill="currentColor" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>',
 lock:'<path d="M7 10V7a5 5 0 0 1 10 0v3" fill="none" stroke="currentColor" stroke-width="3"/><rect x="4" y="9" width="16" height="13" rx="4" fill="currentColor"/><path d="M12 14v3" stroke="#efeee7" stroke-width="2.5" stroke-linecap="round"/>',
 cup:'<path d="M4 8h14v7c0 5-14 5-14 0Z" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linejoin="round"/><path d="M18 9h1a3 3 0 0 1 0 6h-1M3 22h17M8 2v2m6-2v2" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" fill="none"/>',
 book:'<path d="M12 5c-2-2-5-3-9-2v16c4-1 7 0 9 2 2-2 5-3 9-2V3c-4-1-7 0-9 2Z" fill="var(--icon-fill, #fffef8)" stroke="#242522" stroke-width="2.2" stroke-linejoin="round"/><path d="M12 5v16M6 7h3m-3 4h3m6-4h3m-3 4h3" stroke="#242522" stroke-width="1.8" stroke-linecap="round"/>',
 review:'<circle cx="12" cy="12" r="8.5" fill="var(--icon-fill, #fffef8)" stroke="#242522" stroke-width="2.2"/><path d="M12 7v5l3 2M3.5 3.5v5h5" fill="none" stroke="#242522" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>',
 trophy:'<path d="M6 3h12v7c0 7-12 7-12 0Z" fill="var(--icon-fill, #fffef8)" stroke="#242522" stroke-width="2.2" stroke-linejoin="round"/><path d="M6 5H2v3c0 4 3 5 5 5m11-8h4v3c0 4-3 5-5 5M12 15v6m-4 0h8" stroke="#242522" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>',
 user:'<circle cx="12" cy="6" r="4" fill="var(--icon-fill, #fffef8)" stroke="#242522" stroke-width="2.2"/><path d="M4 21v-3c0-9 16-9 16 0v3Z" fill="var(--icon-fill, #fffef8)" stroke="#242522" stroke-width="2.2" stroke-linejoin="round"/>',
 sound:'<path d="M3 9h4l5-4v14l-5-4H3Z" fill="currentColor"/><path d="M16 8a6 6 0 0 1 0 8m3-11a10 10 0 0 1 0 14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>',
 mute:'<path d="M3 9h4l5-4v14l-5-4H3Z" fill="currentColor"/><path d="m16 9 5 6m0-6-5 6" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>',
 spark:'<path d="M12 1c0 8-3 11-11 11 8 0 11 3 11 11 0-8 3-11 11-11-8 0-11-3-11-11Z" fill="currentColor"/>',
 target:'<circle cx="12" cy="12" r="9" fill="none" stroke="currentColor" stroke-width="2.5"/><circle cx="12" cy="12" r="4" fill="none" stroke="currentColor" stroke-width="2.3"/><circle cx="12" cy="12" r="1.5" fill="currentColor"/>',
 share:'<path d="M12 15V3m0 0 4 4m-4-4L8 7M5 12v7h14v-7" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"/>',
 compass:'<circle cx="12" cy="12" r="9" fill="var(--icon-fill, #fffef8)" stroke="#242522" stroke-width="2.2"/><path d="m15.5 8.5-2 5-5 2 2-5Z" fill="#ffd83d" stroke="#242522" stroke-width="1.8" stroke-linejoin="round"/>',
 flag:'<path d="M5 21V3m0 1h12l-2 4 2 4H5" fill="var(--icon-fill, #fffef8)" stroke="#242522" stroke-width="2.2" stroke-linejoin="round"/><path d="M5 21V3" stroke="#242522" stroke-width="2.2" stroke-linecap="round"/>'
};
const icon=(name,cls='')=>`<svg class="icon ${cls}" viewBox="0 0 24 24" aria-hidden="true">${icons[name]||icons.star}</svg>`;

function bird(mood='wave'){
 const smile=['happy','celebrate'].includes(mood);
 const leftWing=smile?'<path d="M51 105C34 103 14 89 13 75c-1-9 15-3 23 1l21 18" fill="#FFD83D"/>':'<path d="M50 110C24 110 22 97 24 87c1-6 12 2 22 5" fill="#E5B820"/>';
 const rightWing=smile?'<path d="M120 100c15-4 27-24 25-31-2-8-16 3-20 10l-11 9" fill="#FFD83D"/>':'<path d="M117 100c17 3 20 16 16 22-6 6-17-3-23-12" fill="#E5B820"/>';
 let eyes=smile?'<path d="M66 91q7-10 14 0m18 0q7-10 14 0" fill="none"/>':'<ellipse cx="73" cy="88" rx="4.7" ry="7" fill="#242522" stroke="none"/><ellipse cx="106" cy="88" rx="4.7" ry="7" fill="#242522" stroke="none"/>';
 if(mood==='think')eyes='<path d="m65 77 15-3m18 1 12 4" fill="none"/><ellipse cx="73" cy="91" rx="4.5" ry="6" fill="#242522" stroke="none"/><ellipse cx="106" cy="90" rx="4.5" ry="6" fill="#242522" stroke="none"/>';
 if(mood==='wave')eyes='<ellipse cx="73" cy="88" rx="4.7" ry="7" fill="#242522" stroke="none"/><path d="M99 87q6-7 13 0" fill="none"/>';
 return `<svg class="bird" viewBox="0 0 160 180" aria-hidden="true"><g stroke="#242522" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="84" cy="165" rx="37" ry="5" fill="#242522" opacity="${mood==='celebrate'?'0':'.1'}" stroke="none"/><path d="m68 148-5 12-9 2m42-14 4 12 9 2" fill="none"/><path d="m71 56-14-18c-7-12 6-14 12-3l7 13m0 7-1-25c0-14 15-11 12 1l-4 21m-1 1 10-18c7-11 17-3 8 6l-13 16" fill="#FFD83D"/>${leftWing}${rightWing}<path d="M41 126c-10-24-5-58 21-69 24-11 50-1 61 21 14 26 13 55-8 66-15 9-63 13-74-18Z" fill="#FFD83D"/><path d="M41 122c9 23 51 33 78 16-7 16-24 18-43 17-20-1-32-8-35-24Z" fill="#E5B820" stroke="none"/><ellipse cx="88" cy="126" rx="23" ry="20" fill="#FFE984" stroke="none"/>${eyes}<ellipse cx="61" cy="102" rx="8" ry="5" fill="#F47861" stroke="none"/><ellipse cx="118" cy="102" rx="7" ry="5" fill="#F47861" stroke="none"/><path d="m83 99 15 1-7 10Z" fill="#F47861"/>${smile?'<path d="M82 112q9 12 18-1c-2 15-16 18-18 1Z" fill="#242522" stroke-width="2"/><path d="M86 121q5-4 9-1" stroke="#F47861" stroke-width="3"/>':''}<path d="M45 106q3 13 12 17" fill="none" stroke="#D4A91B" stroke-width="4"/></g>${mood==='celebrate'?'<path d="m126 33 7-8m-4 21 12-2M27 39l-6-8" stroke="#242522" stroke-width="3" stroke-linecap="round"/>':''}</svg>`;
}

/* ---------------------------------------------------------------- option art */
const optionArt={
 small:'<svg viewBox="0 0 96 96" aria-hidden="true"><path d="M33 38h32v24c0 9-10 12-16 12s-16-3-16-12Z" fill="#fffef8" stroke="#242522" stroke-width="3" stroke-linejoin="round"/><path d="M65 43h3a6 6 0 0 1 0 12h-3" fill="none" stroke="#242522" stroke-width="3" stroke-linecap="round"/><path d="M27 79h44" stroke="#242522" stroke-width="3" stroke-linecap="round"/><path d="M43 30c0-4 4-4 4-8m8 8c0-4 4-4 4-8" fill="none" stroke="#242522" stroke-width="2.4" stroke-linecap="round"/><path d="M39 48h20" stroke="#ffd83d" stroke-width="5" stroke-linecap="round"/></svg>',
 large:'<svg viewBox="0 0 96 96" aria-hidden="true"><path d="M24 34h48v28c0 12-14 16-24 16s-24-4-24-16Z" fill="#fffef8" stroke="#242522" stroke-width="3" stroke-linejoin="round"/><path d="M72 40h4a7 7 0 0 1 0 14h-4" fill="none" stroke="#242522" stroke-width="3" stroke-linecap="round"/><path d="M19 84h58M24 54h48" stroke="#242522" stroke-width="3" stroke-linecap="round"/><path d="M20 34h56" stroke="#ffd83d" stroke-width="6" stroke-linecap="round"/></svg>',
 iced:'<svg viewBox="0 0 96 96" aria-hidden="true"><path d="M31 39h34v25c0 10-10 13-17 13s-17-3-17-13Z" fill="#fffef8" stroke="#242522" stroke-width="3" stroke-linejoin="round"/><path d="M65 44h3a6 6 0 0 1 0 12h-3" fill="none" stroke="#242522" stroke-width="3" stroke-linecap="round"/><path d="M29 80h42" stroke="#242522" stroke-width="3" stroke-linecap="round"/><path d="m53 36 9-22" stroke="#f47861" stroke-width="5" stroke-linecap="round"/><rect x="39" y="48" width="8" height="8" rx="2" fill="#b9eadd" stroke="#242522" stroke-width="2"/><rect x="50" y="58" width="8" height="8" rx="2" fill="#b9eadd" stroke="#242522" stroke-width="2"/><rect x="40" y="63" width="7" height="7" rx="2" fill="#b9eadd" stroke="#242522" stroke-width="2"/></svg>',
 left:'<svg viewBox="0 0 96 96" aria-hidden="true"><rect x="17" y="20" width="62" height="56" rx="14" fill="#fffef8" stroke="#242522" stroke-width="3"/><path d="M62 48H35m10-12L33 48l12 12" fill="none" stroke="#242522" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/><path d="M62 32v32" stroke="#ffd83d" stroke-width="6" stroke-linecap="round"/></svg>',
 right:'<svg viewBox="0 0 96 96" aria-hidden="true"><rect x="17" y="20" width="62" height="56" rx="14" fill="#fffef8" stroke="#242522" stroke-width="3"/><path d="M34 48h27M51 36l12 12-12 12" fill="none" stroke="#242522" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/><path d="M34 32v32" stroke="#ffd83d" stroke-width="6" stroke-linecap="round"/></svg>',
 straight:'<svg viewBox="0 0 96 96" aria-hidden="true"><rect x="17" y="20" width="62" height="56" rx="14" fill="#fffef8" stroke="#242522" stroke-width="3"/><path d="M48 66V34M36 46l12-12 12 12" fill="none" stroke="#242522" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/><path d="M34 66h28" stroke="#ffd83d" stroke-width="6" stroke-linecap="round"/></svg>'
};

/* ---------------------------------------------------------------- course data */
const lessons={
 coffee:{
  id:'coffee',title:'点杯咖啡',nodeTitle:'点杯咖啡',eyebrow:'第 3 课',xp:24,estimated:'约 2 分钟',icon:'cup',
  questions:[
   {type:'fill',prompt:'帮 Pip 点杯咖啡',cn:'来一杯加奶的咖啡。',first:"I'd like a coffee",prefix:'with',suffix:'.',words:['coffee','milk','tea','water'],answer:'milk',explain:'with milk = 加奶',audio:'coffee-milk'},
   {type:'fill',prompt:'告诉店员，你想带走',cn:'这杯咖啡可以打包吗？',first:'Can I get it',prefix:'',suffix:'?',words:['to go','here','today','again'],answer:'to go',explain:'to go = 打包带走',audio:'to-go'},
   {type:'fill',prompt:'选好杯型就出发',cn:'小杯的，谢谢。',first:'A',prefix:'',suffix:'one, please.',words:['large','cold','small','sweet'],answer:'small',explain:'a small one = 小杯的',audio:'small'},
   {type:'listen',prompt:'听一听，Pip 点了哪一杯？',cn:'先听英文，再选出对应的杯型。',audio:'small',audioText:'A small one, please.',options:[{id:'small',label:'小杯',sub:'small',art:'small'},{id:'large',label:'大杯',sub:'large',art:'large'},{id:'iced',label:'冰杯',sub:'iced',art:'iced'}],answer:'small',explain:'a small one = 小杯的'},
   {type:'fill',prompt:'给店员一个好心情',cn:'谢谢。祝你今天愉快！',first:'',prefix:'',suffix:'. Have a nice day!',words:['Sorry','Hello','Thank you','Good night'],answer:'Thank you',explain:'Have a nice day! = 祝你愉快！',audio:'thank-you'}
  ]
 },
 directions:{
  id:'directions',title:'问个方向',nodeTitle:'问个方向',eyebrow:'第 4 课',xp:24,estimated:'约 2 分钟',icon:'compass',
  questions:[
   {type:'fill',prompt:'先礼貌地问个路',cn:'请问，车站在哪里？',first:'Excuse me, where is the',prefix:'',suffix:'?',words:['station','coffee','menu','bank'],answer:'station',explain:'station = 车站',audio:'where-station'},
   {type:'fill',prompt:'店员告诉你怎么走',cn:'直走两个街区。',first:'Go',prefix:'',suffix:'for two blocks.',words:['straight','back','slow','around'],answer:'straight',explain:'go straight = 直走',audio:'go-straight'},
   {type:'listen',prompt:'听一听，路口该怎么转？',cn:'先听英文，再选出正确的方向。',audio:'turn-left',audioText:'Turn left at the corner.',options:[{id:'left',label:'左转',sub:'turn left',art:'left'},{id:'right',label:'右转',sub:'turn right',art:'right'},{id:'straight',label:'直走',sub:'go straight',art:'straight'}],answer:'left',explain:'turn left = 左转'},
   {type:'fill',prompt:'确认目的地的位置',cn:'就在银行旁边。',first:"It's",prefix:'',suffix:'the bank.',words:['next to','far from','under','behind'],answer:'next to',explain:'next to = 在…旁边',audio:'next-to-bank'}
  ]
 },
 challenge:{
  id:'challenge',title:'单元挑战',nodeTitle:'单元挑战',eyebrow:'咖啡店单元',xp:50,estimated:'约 3 分钟',icon:'flag',
  questions:null
 }
};
lessons.challenge.questions=[
 lessons.coffee.questions[0],
 lessons.coffee.questions[1],
 lessons.coffee.questions[3],
 lessons.directions.questions[0],
 lessons.directions.questions[1],
 lessons.directions.questions[2]
];

const lessonOrder=['coffee','directions','challenge'];

const reviewTopics={
 coffee:{title:'点杯咖啡',copy:'咖啡店的 5 个说法，排队时也能顺口说出来。',icon:'cup',topic:'coffee',terms:[
  {en:'milk',cn:'牛奶'},{en:'to go',cn:'打包带走'},{en:'a small one',cn:'小杯的'},{en:'Thank you',cn:'谢谢'},{en:'Have a nice day!',cn:'祝你今天愉快！'}
 ]},
 greeting:{title:'打个招呼',copy:'把这 4 句说顺，见面就不紧张。',icon:'book',topic:'greeting',terms:[
  {en:'Hello.',cn:'你好。'},{en:'Nice to meet you.',cn:'很高兴认识你。'},{en:'How are you?',cn:'你好吗？'},{en:'See you.',cn:'回头见。'}
 ]},
 menu:{title:'看懂菜单',copy:'下次买咖啡，认得这些就够用。',icon:'review',topic:'menu',terms:[
  {en:'a latte',cn:'一杯拿铁'},{en:'an espresso',cn:'一杯浓缩咖啡'},{en:'iced coffee',cn:'冰咖啡'},{en:'decaf',cn:'低因咖啡'}
 ]},
 directions:{title:'问个方向',copy:'问路、找店、确认位置，一次练顺。',icon:'compass',topic:'directions',terms:[
  {en:'station',cn:'车站'},{en:'go straight',cn:'直走'},{en:'turn left',cn:'左转'},{en:'next to',cn:'在…旁边'}
 ]}
};
const allTerms=Object.values(reviewTopics).flatMap(t=>t.terms);
const totalTermCount=allTerms.length;

/* ---------------------------------------------------------------- helpers */
const reduceMotion=()=>matchMedia('(prefers-reduced-motion: reduce)').matches;
function dateKey(offset=0){
 const d=new Date();
 d.setHours(12,0,0,0);
 d.setDate(d.getDate()+offset);
 return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}
const todayKey=()=>dateKey(0);
function computeStreak(dates){
 const set=new Set(dates);
 let cursor=set.has(todayKey())?0:1;
 let count=0;
 while(set.has(dateKey(-cursor))){count++;cursor++;}
 return count;
}
function defaultState(){
 const dates=[];
 for(let i=7;i>=1;i--)dates.push(dateKey(-i));
 return {
  xp:1284,lives:4,streak:computeStreak(dates),studyDates:dates,
  dailyGoal:10,dailySeconds:360,dailyDate:todayKey(),
  completedLessons:{greeting:true,menu:true,coffee:false,directions:false,challenge:false},
  reviewMastered:{coffee:[],greeting:[],menu:[],directions:[]},
  run:null,pausedRuns:{},lastResult:null,soundOn:false
 };
}
function loadState(){
 if(wall)return defaultState();
 try{
  const raw=JSON.parse(localStorage.getItem('pip-learning-v2')||'null');
  if(!raw)return defaultState();
  const d=defaultState();
  const s={...d,...raw,completedLessons:{...d.completedLessons,...(raw.completedLessons||{})},reviewMastered:{...d.reviewMastered,...(raw.reviewMastered||{})},pausedRuns:{...(raw.pausedRuns||{})}};
  if(!Array.isArray(s.studyDates))s.studyDates=d.studyDates;
  if(s.dailyDate!==todayKey()){s.dailyDate=todayKey();s.dailySeconds=0;}
  s.streak=computeStreak(s.studyDates);
  return s;
 }catch{return defaultState();}
}
let saved=loadState();
let soundOn=params.get('sound')==='on'||saved.soundOn!==false;
const persist=()=>{if(wall)return;try{localStorage.setItem('pip-learning-v2',JSON.stringify(saved))}catch{}};
function save(){saved.streak=computeStreak(saved.studyDates);persist();}

let screen='path';
let lastResult=saved.lastResult||null;
let deck=null;
let modalId=null;
let toastTimer=null;
let audio=null;

const contentScreens=['path','quiz','complete','reviewHub','reviewDeck','achievements','profile'];
const requested=params.get('screen');
if(requested){
 if(requested==='review')screen='reviewHub';
 else if(contentScreens.includes(requested))screen=requested;
}
if(!contentScreens.includes(screen))screen='path';

/* ---------------------------------------------------------------- run helpers */
const totalMastered=()=>Object.values(saved.reviewMastered).reduce((n,list)=>n+(list?.length||0),0);
const currentQuestion=()=>{
 if(!saved.run)return null;
 const lesson=lessons[saved.run.lessonId];
 return lesson?.questions[saved.run.qIndex]||null;
};
const runMatches=(lessonId,mode)=>{
 const r=saved.run;
 return !!r&&r.lessonId===lessonId&&r.mode===mode&&r.awarded!==true;
};
function createRun(lessonId,mode){
 return {lessonId,mode,qIndex:0,answered:0,correctFirstTry:0,selection:'',feedback:'',firstTry:true,streak:0};
}
function currentLessonId(){
 if(!saved.completedLessons.coffee)return 'coffee';
 if(!saved.completedLessons.directions)return 'directions';
 if(!saved.completedLessons.challenge)return 'challenge';
 return null;
}
function unlocked(id){
 if(id==='coffee')return true;
 if(id==='directions')return !!saved.completedLessons.coffee;
 if(id==='challenge')return !!saved.completedLessons.directions;
 return false;
}
function markStudyToday(){
 const t=todayKey();
 if(saved.dailyDate!==t){saved.dailyDate=t;saved.dailySeconds=0;}
 if(!saved.studyDates.includes(t)){
  saved.studyDates.push(t);
  saved.studyDates=[...new Set(saved.studyDates)].sort();
  saved.streak=computeStreak(saved.studyDates);
 }
}
function addLearningTime(seconds){
 markStudyToday();
 saved.dailySeconds=Math.min(saved.dailyGoal*60,saved.dailySeconds+seconds);
 save();
}
function startLesson(id,mode='lesson'){
 const lesson=lessons[id];
 if(!lesson)return;
 if(!unlocked(id)){
  toast(id==='directions'?'先完成「点杯咖啡」，就能解锁「问个方向」。':'先完成「问个方向」，就能解锁单元挑战。');
  modalId=null;
  go('path');
  return;
 }
 if(!saved.completedLessons[id]&&mode==='review')mode='lesson';
 if(saved.completedLessons[id]&&mode==='lesson')mode='review';
 const key=id+':'+mode;
 if(runMatches(id,mode)){
  // keep the exact saved state
 }else if(saved.pausedRuns?.[key]){
  if(saved.run&&saved.run.awarded!==true){
   saved.pausedRuns[saved.run.lessonId+':'+saved.run.mode]=saved.run;
  }
  saved.run=saved.pausedRuns[key];
  delete saved.pausedRuns[key];
 }else{
  if(saved.run&&saved.run.awarded!==true){
   saved.pausedRuns[saved.run.lessonId+':'+saved.run.mode]=saved.run;
  }
  saved.run=createRun(id,mode);
 }
 if(saved.lives<=0)saved.lives=4;
 stopAudio();
 save();
 screen='quiz';
 render();
 focusHeading();
}
function startCurrentLesson(){
 const id=currentLessonId();
 if(id){
  if(saved.run&&saved.run.lessonId===id&&saved.run.awarded!==true){
   startLesson(id,saved.run.mode);
  }else{
   startLesson(id,saved.completedLessons[id]?'review':'lesson');
  }
 }else{
  startLesson('coffee','review');
 }
}
function finishRun(){
 const run=saved.run;
 if(!run)return;
 stopAudio();
 const lesson=lessons[run.lessonId];
 const total=lesson.questions.length;
 const accuracy=Math.round(run.correctFirstTry/total*100);
 let xpAwarded=0,completedNow=false;
 if(run.mode!=='review'&&!saved.completedLessons[lesson.id]){
  xpAwarded=lesson.xp;
  saved.xp+=xpAwarded;
  saved.completedLessons[lesson.id]=true;
  completedNow=true;
 }
 const result={
  lessonId:lesson.id,title:lesson.title,eyebrow:lesson.eyebrow,xpAwarded,accuracy,
  correctFirstTry:run.correctFirstTry,total,mode:run.mode,
  completedNow,streak:saved.streak,dailySeconds:saved.dailySeconds,
  dailyGoal:saved.dailyGoal,allDone:!currentLessonId()
 };
 saved.lastResult=result;
 saved.run=null;
 if(saved.pausedRuns){
  for(const k of Object.keys(saved.pausedRuns)){
   if(k.startsWith(lesson.id+':'))delete saved.pausedRuns[k];
  }
 }
 save();
 lastResult=result;
 screen='complete';
 render();
 focusHeading();
 chirp();
}

/* ---------------------------------------------------------------- navigation / focus */
function stopAudio(){
 if(audio){audio.pause();audio=null;}
 try{window.speechSynthesis?.cancel();}catch{}
}
function go(next){
 stopAudio();
 screen=next;
 render();
 focusHeading();
}
function focusHeading(){
 const h=app.querySelector('h1');
 if(h){h.tabIndex=-1;h.focus({preventScroll:true});}
}
function toast(message){
 clearTimeout(toastTimer);
 app.querySelector('.toast')?.remove();
 const el=document.createElement('div');
 el.className='toast';el.setAttribute('role','status');el.textContent=message;
 app.append(el);
 toastTimer=setTimeout(()=>el.remove(),4300);
}

/* ---------------------------------------------------------------- audio */
function chirp(){
 if(!soundOn||reduceMotion())return;
 try{
  const AudioCtx=window.AudioContext||window.webkitAudioContext;
  const ctx=new AudioCtx();
  [660,880,1174].forEach((f,i)=>{
   const osc=ctx.createOscillator(),gain=ctx.createGain();
   osc.type='sine';osc.frequency.value=f;
   gain.gain.setValueAtTime(0,ctx.currentTime+i*.075);
   gain.gain.linearRampToValueAtTime(.08,ctx.currentTime+i*.075+.012);
   gain.gain.exponentialRampToValueAtTime(.001,ctx.currentTime+i*.075+.12);
   osc.connect(gain);gain.connect(ctx.destination);
   osc.start(ctx.currentTime+i*.075);osc.stop(ctx.currentTime+i*.075+.13);
  });
  setTimeout(()=>ctx.close(),500);
 }catch{}
}
function setAudioLabels(button,playing){
 if(!button)return;
 const strong=button.querySelector('[data-audio-title]');
 const small=button.querySelector('[data-audio-hint]');
 const span=button.querySelector('span');
 if(strong)strong.textContent=playing?'正在播放…':'再听一遍';
 else if(small&&playing)small.textContent='正在播放…';
 else if(small)small.textContent='点这里再听一遍';
 else if(span)span.textContent=playing?'正在播放…':'再听一遍';
}
function playQuestionAudio(button){
 const q=currentQuestion();
 if(!q)return;
 stopAudio();
 if(q.audio){
  audio=new Audio(`assets/${q.audio}.wav`);
  setAudioLabels(button,true);
  audio.addEventListener('ended',()=>{setAudioLabels(button,false);});
  const fail=()=>{setAudioLabels(button,false);toast('这次没播放出来，点一下再听。');};
  audio.addEventListener('error',fail);
  audio.play().catch(fail);
 }else if(q.audioText){
  speak(q.audioText,button);
 }else{
  toast('这道题没有音频。');
 }
}
function speak(text,button){
 if(!('speechSynthesis' in window)){
  setAudioLabels(button,false);
  toast('这个浏览器不支持语音播放。');
  return;
 }
 stopAudio();
 try{
  const u=new SpeechSynthesisUtterance(text);
  u.lang='en-US';u.rate=.88;
  setAudioLabels(button,true);
  u.onend=()=>setAudioLabels(button,false);
  u.onerror=()=>setAudioLabels(button,false);
  window.speechSynthesis.speak(u);
 }catch{
  setAudioLabels(button,false);
  toast('这次没播放出来，点一下再听。');
 }
}

/* ---------------------------------------------------------------- shared UI */
const sentenceTail=suffix=>{
 const punctuation=/^([.?])(.*)$/.exec(suffix);
 return punctuation?`<span class="sentence-stop">${punctuation[1]}</span>${punctuation[2]}`:` <span>${suffix}</span>`;
};
function topResources(){
 return `<div class="resources"><span class="resource" aria-label="连续学习 ${saved.streak} 天">${icon('flame')}<b class="number">${saved.streak}</b><small>天</small></span><span class="resource xp" aria-label="${saved.xp} 经验值">${icon('bolt')}<b class="number">${saved.xp.toLocaleString()}</b><small>XP</small></span><span class="resource" aria-label="剩余 ${saved.lives} 颗生命">${icon('heart')}<b class="number">${saved.lives}</b></span></div>`;
}
function nav(active){
 const item=(id,label,ic)=>`<button class="nav-btn ${active===id?'active':''}" data-action="nav" data-screen="${id}" ${active===id?'aria-current="page"':''}>${icon(ic)}<span>${label}</span></button>`;
 return `<nav class="bottom-nav" aria-label="主导航">${item('path','学习','book')}${item('reviewHub','复习','review')}${item('achievements','成就','trophy')}${item('profile','我的','user')}</nav>`;
}
function dailyBar(){
 const goalSeconds=saved.dailyGoal*60;
 const minutes=Math.min(saved.dailyGoal,Math.floor(saved.dailySeconds/60));
 const pct=Math.min(100,Math.round(saved.dailySeconds/goalSeconds*100));
 const done=saved.dailySeconds>=goalSeconds;
 return `<div class="daily"><div class="daily-label">今日目标<span>${minutes} / ${saved.dailyGoal} 分钟${done?' · 已完成':''}</span></div><div class="daily-track" role="progressbar" aria-label="今日学习目标" aria-valuenow="${minutes}" aria-valuemin="0" aria-valuemax="${saved.dailyGoal}"><i style="width:${pct}%"></i></div></div>`;
}
function weekRow(){
 const names=['日','一','二','三','四','五','六'];
 let html='';
 for(let i=6;i>=0;i--){
  const key=dateKey(-i);
  const d=new Date();d.setHours(12,0,0,0);d.setDate(d.getDate()-i);
  const studied=saved.studyDates.includes(key);
  const today=i===0;
  html+=`<div class="day ${today?'today':''} ${studied?'studied':''}"><span class="day-label">${today?'今天':names[d.getDay()]}</span><span class="day-disc">${studied?icon('check'):'<i class="day-dot"></i>'}</span></div>`;
 }
 return `<div class="week" aria-label="最近七天学习记录">${html}</div>`;
}
function streakBlock(){
 return `<div class="streak-block"><div class="streak-head">${icon('flame')}<div><h2>连续学习 <span class="number">${saved.streak}</span> 天！</h2></div></div>${weekRow()}</div>`;
}
function rewardRow(result){
 const rewardLabel=result.xpAwarded? (result.lessonId==='challenge'?'挑战奖励':'本课经验') : '复习成果';
 const rewardValue=result.xpAwarded? `${icon('bolt')}<span>+${result.xpAwarded} <small>XP</small></span>` : `<span><small>已巩固</small></span>`;
 return `<div class="reward-row"><div class="reward"><div class="reward-label">${rewardLabel}</div><div class="reward-value">${rewardValue}</div></div><div class="reward mint"><div class="reward-label">正确率</div><div class="reward-value">${icon('target')}<span>${result.accuracy}<small>%</small></span></div></div></div>`;
}

/* ---------------------------------------------------------------- path */
function nodeState(id){
 if(id==='greeting'||id==='menu')return 'completed';
 if(!unlocked(id))return 'locked';
 if(saved.completedLessons[id])return 'completed';
 if(currentLessonId()===id)return 'current';
 return 'completed';
}
function nodeMarkup(id,cls,label){
 const state=nodeState(id);
 const resumable=state==='current'&&((saved.run&&saved.run.lessonId===id&&saved.run.awarded!==true)||saved.pausedRuns?.[id+':lesson']||saved.pausedRuns?.[id+':review']);
 const aria=state==='completed'?`已完成：${label}，复习`:(state==='locked'?`未解锁：${label}`:`${resumable?'继续':'开始'}：${label}`);
 const inner=state==='completed'?icon('check'):state==='locked'?icon('lock'):icon('play');
 return `<button class="level ${state} ${cls}" data-action="node" data-id="${id}" data-state="${state}" aria-label="${aria}">${inner}</button><span class="node-label label${cls.slice(1)}">${label}</span>`;
}
function pathScreen(){
 const current=currentLessonId();
 const pausedCurrent=current? (saved.pausedRuns?.[current+':lesson']||saved.pausedRuns?.[current+':review']) : null;
 const activeRun=(saved.run&&saved.run.lessonId===current&&saved.run.awarded!==true)?saved.run:pausedCurrent;
 const lesson=current?lessons[current]:null;
 let ctaLabel='复习点单',meta='本单元已通关 · 可随时复习';
 if(current){
  if(activeRun){
   ctaLabel=activeRun.mode==='review'?'继续复习':'继续这一课';
   meta=`已完成 ${activeRun.answered} / ${lessons[current].questions.length} 题`;
  }else{
   ctaLabel=current==='coffee'?'开始这一课':current==='directions'?'学习问路':'开始单元挑战';
   meta=`${lesson.questions.length} 道题 · ${lesson.estimated}`;
  }
 }else if(saved.run&&saved.run.awarded!==true){
  // an unfinished review run when the unit is already complete
  ctaLabel=saved.run.mode==='review'?'继续复习':'继续这一课';
  meta=`已完成 ${saved.run.answered} / ${lessons[saved.run.lessonId].questions.length} 题`;
 }
 const allDone=!current;
 const metaMarkup=allDone?`<span class="unit-done">${icon('trophy')}本单元已通关 · 可随时复习</span>`:`<span>${meta}</span>`;
 const donePath=saved.completedLessons.challenge
  ?'M173 49C169 89 100 91 105 126S146 174 163 209s91 48 87 96-77 44-77 84'
  :saved.completedLessons.directions
   ?'M173 49C169 89 100 91 105 126S146 174 163 209s91 48 87 96'
   :'M173 49C169 89 100 91 105 126s20 53 58 83';
 return `<section class="screen path"><header class="topbar"><div class="brand" aria-label="Pip">pip</div>${topResources()}</header><div class="unit-banner"><div><p class="unit-eyebrow">第 3 单元 · 通勤英语</p><h1 tabindex="-1">咖啡店，开口不慌</h1></div>${icon('cup','unit-icon')}</div>${dailyBar()}<div class="map" aria-label="学习关卡路线"><svg class="trail" viewBox="0 0 350 425" preserveAspectRatio="none" aria-hidden="true"><path class="base" d="M173 49C169 89 100 91 105 126S146 174 163 209s91 48 87 96-77 44-77 84"/><path class="done" d="${donePath}"/></svg>${nodeMarkup('greeting','l1','打个招呼')}${nodeMarkup('menu','l2','看懂菜单')}${nodeMarkup('coffee','l3','点杯咖啡')}<div class="map-bird">${bird(allDone?'celebrate':'wave')}</div>${nodeMarkup('directions','l4','问个方向')}${nodeMarkup('challenge','l5','单元挑战')}</div><div class="next-lesson"><div class="lesson-meta">${metaMarkup}</div><button class="button" data-action="start-lesson">${ctaLabel}${icon('arrow')}</button></div>${nav('path')}</section>`;
}

/* ---------------------------------------------------------------- quiz */
function questionTypeLabel(q){return q.type==='listen'?'听音选图':'选词填空';}
function renderListenOptions(q){
 const right=saved.run.feedback==='correct';
 const wrong=saved.run.feedback==='wrong';
 return `<div class="listen-options" role="group" aria-label="选择对应图片">${q.options.map(o=>{
  const selected=saved.run.selection===o.id;
  return `<button class="picture-option ${selected?'selected':''}" data-word="${o.id}" aria-pressed="${selected}" ${saved.run.feedback?'disabled':''}><span class="option-art">${optionArt[o.art]}</span><span class="option-label">${o.label}</span><span class="option-sub">${o.sub}</span>${selected&&right?icon('check'):selected&&wrong?icon('close'):''}</button>`;
 }).join('')}</div>`;
}
function renderFill(q){
 const right=saved.run.feedback==='correct';
 const wrong=saved.run.feedback==='wrong';
 const selection=saved.run.selection;
 return `<div class="sentence" aria-label="${q.first} ${q.prefix} ${selection||'空白'} ${q.suffix}">${q.first?`<div class="sentence-line">${q.first}</div>`:''}<div>${q.prefix?q.prefix+' ':''}<span class="blank ${selection?'filled':''}">${selection||'···'}${right?icon('check'):''}</span>${sentenceTail(q.suffix)}</div></div><div class="word-bank" role="group" aria-label="选择填空单词">${q.words.map(w=>right&&selection===w?'<span class="word word-slot" aria-hidden="true"></span>':`<button class="word ${selection===w?'selected':''}" data-word="${w}" aria-pressed="${selection===w}" ${saved.run.feedback?'disabled':''}>${w}${selection===w&&!right?icon(wrong?'close':'check'):''}</button>`).join('')}</div>`;
}
function quizScreen(){
 const run=saved.run;
 if(!run)return pathScreen();
 const lesson=lessons[run.lessonId];
 const q=currentQuestion();
 if(!q)return pathScreen();
 const total=lesson.questions.length;
 const right=run.feedback==='correct';
 const wrong=run.feedback==='wrong';
 const pct=Math.round(run.answered/total*100);
 const isLast=run.qIndex===total-1;
 const modeChip=run.mode==='review'?'复习':run.lessonId==='challenge'?'挑战':'';
 const combo=right&&run.streak>=2?`<div class="combo">${icon('bolt')}${run.streak} 连击</div>`:'';
 const nextLabel=isLast?(run.lessonId==='challenge'?'查看挑战结果':'查看本课成果'):'继续下一题';
 const dialogue=q.type==='listen'
  ?`<div class="dialogue">${right?'':`<div class="dialogue-bird">${bird('think')}</div>`}<div class="speech">${q.cn}</div></div>`
  :`<div class="dialogue">${right?'':`<div class="dialogue-bird">${bird('think')}</div>`}<div class="speech">${q.cn}<button class="listen" data-action="listen" aria-label="播放英文发音">${icon('sound')}<span>听听怎么说</span></button></div></div>`;
 const body=q.type==='listen'
  ?`${dialogue}<button class="audio-prompt" data-action="listen" aria-label="播放英文"><span class="audio-disc">${icon('sound')}</span><span class="audio-copy"><strong data-audio-title>播放英文</strong><small data-audio-hint>听完选出对应的图片</small></span></button>${renderListenOptions(q)}`
  :`${dialogue}${renderFill(q)}`;
 return `<section class="screen quiz ${right?'is-correct':''} ${wrong?'is-wrong':''} ${right&&run.animate?'pop':''}"><header class="lesson-top"><button class="plain-btn" data-action="leave" aria-label="退出本课，保留答题进度">${icon('close')}</button><div class="progress" role="progressbar" aria-label="本课进度" aria-valuenow="${run.answered}" aria-valuemin="0" aria-valuemax="${total}"><i style="width:${pct}%"></i></div><span class="resource" aria-label="剩余 ${saved.lives} 颗生命">${icon('heart')}<b class="number">${saved.lives}</b></span></header><div class="quiz-main"><div class="question-meta"><span>${modeChip?modeChip+' · ':''}${questionTypeLabel(q)} · ${run.qIndex+1} / ${total}</span><button class="sound-toggle" data-action="sound" aria-label="${soundOn?'关闭':'开启'}答题音效" aria-pressed="${soundOn}">${icon(soundOn?'sound':'mute')}</button></div><h1 tabindex="-1">${q.prompt}</h1>${body}</div><footer class="quiz-footer ${run.feedback}" aria-live="polite">${right?`<div class="feedback-bird">${bird('celebrate')}</div>${combo}<div class="feedback-heading"><span class="check-disc">${icon('check')}</span><h2>答对了！</h2></div><p class="feedback-copy">${q.explain}</p><button class="button" data-action="next">${nextLabel}${icon('arrow')}</button>`:wrong?`<div class="feedback-heading"><span class="check-disc">${icon('close')}</span><h2>差一点，再试试</h2></div><p class="feedback-copy">${q.explain}。把这个说法记住！</p><button class="button" data-action="retry">${saved.lives===0?'补满生命，再试一次':'再选一次'}${icon('review')}</button>`:`<button class="button" data-action="check" ${run.selection?'':'disabled'}>检查答案</button><p class="hint">${run.selection?'':'选一个答案，补全这道题。'}</p>`}</footer></section>`;
}

/* ---------------------------------------------------------------- complete */
function demoResult(){
 return {lessonId:'coffee',title:'点杯咖啡',eyebrow:'第 3 课',xpAwarded:24,accuracy:100,correctFirstTry:5,total:5,mode:'lesson',completedNow:true,streak:saved.streak,dailySeconds:saved.dailySeconds,dailyGoal:saved.dailyGoal,allDone:false,demo:true};
}
function completeScreen(){
 const result=lastResult||demoResult();
 if(!result)return pathScreen();
 const copy=result.lessonId==='challenge'
  ?{title:'整条街，都敢开口了！',sub:'咖啡和问路，一次打通。'}
  : result.lessonId==='directions'
   ?{title:'这条路，你走通了！',sub:'下次问路，别再只靠手势。'}
   : result.mode==='review'
    ?{title:'又练了一遍，更顺了！',sub:'重复，是把句子变成本能的方式。'}
    :{title:'这杯英语，你拿下了！',sub:'下次点咖啡，试着用英语说说看。'};
 const goalSeconds=result.dailyGoal*60;
 const remaining=Math.max(0,Math.ceil((goalSeconds-result.dailySeconds)/60));
 const footnote=result.demo?'这是演示结算页，可以直接返回路径。':(remaining>0?`再学 ${remaining} 分钟，完成今日目标。`:'今日目标已完成，明天继续。');
 const cta=result.demo?'返回学习路径':result.allDone&&result.lessonId==='challenge'?'查看单元成就':result.mode==='review'?'返回学习路径':'收下奖励';
 return `<section class="screen finish ${result.demo?'':'finish-enter'}"><header class="finish-top"><div class="brand" aria-label="Pip">pip</div><span>${result.eyebrow||'第 3 课'} · ${result.title}</span></header><div class="celebration"><div class="halo"></div><div class="landing-shadow"></div><div class="celebrate-mark mark1">${icon('spark')}</div><div class="celebrate-mark mark2">${icon('spark')}</div><i class="confetti c1"></i><i class="confetti c2"></i><i class="confetti c3"></i><i class="confetti c4"></i><i class="confetti c5"></i><div class="celebrate-bird">${bird('celebrate')}</div></div><div class="finish-title"><h1 tabindex="-1">${copy.title}</h1><p>${copy.sub}</p></div>${rewardRow(result)}${streakBlock()}<div class="finish-bottom"><button class="button" data-action="finish-cta">${cta}${icon('arrow')}</button><p class="small-text">${footnote}</p></div></section>`;
}

/* ---------------------------------------------------------------- review hub / deck */
function reviewProgress(topic){
 const total=reviewTopics[topic].terms.length;
 const done=saved.reviewMastered[topic]?.length||0;
 return {done,total,pct:total?Math.round(done/total*100):0};
}
function reviewHubScreen(){
 const mastered=totalMastered();
 const pct=totalTermCount?Math.round(mastered/totalTermCount*100):0;
 const cards=Object.keys(reviewTopics).map(id=>{
  const t=reviewTopics[id],p=reviewProgress(id);
  return `<button class="topic-card" data-action="open-deck" data-topic="${id}"><span class="topic-icon">${icon(t.icon)}</span><span class="topic-info"><span class="topic-title">${t.title}</span><span class="topic-copy">${t.copy}</span><span class="topic-progress"><i style="width:${p.pct}%"></i></span><span class="topic-count">已掌握 ${p.done} / ${p.total}</span></span>${icon('arrow','topic-arrow')}</button>`;
 }).join('');
 return `<section class="screen extra-screen"><div class="extra-body"><header class="extra-header"><button class="plain-btn" data-action="nav" data-screen="path" aria-label="返回学习路径">${icon('back')}</button><h1 tabindex="-1">复习</h1></header><div class="review-summary"><div class="review-summary-icon">${icon('review')}</div><div><strong>已经掌握 ${mastered} / ${totalTermCount} 个表达</strong><p>翻一翻词卡，把学过的句子变成自己的。</p></div><div class="review-ring" style="--pct:${pct}"><span>${pct}%</span></div></div><div class="topic-list">${cards}</div></div>${nav('reviewHub')}</section>`;
}
function openDeck(topic,reset=false){
 const t=reviewTopics[topic];
 if(!t)return;
 const mastered=saved.reviewMastered[topic]||[];
 const first=t.terms.findIndex((term,index)=>!mastered.includes(term.en));
 deck={topic,index:first>=0?first:0,revealed:false,done:false,round:reset?1:(deck?.round||1)};
 screen='reviewDeck';
 render();focusHeading();
}
function deckScreen(){
 const t=reviewTopics[deck?.topic||'coffee'];
 const mastered=saved.reviewMastered[t.topic]||[];
 const total=t.terms.length;
 if(deck?.done){
  const all=mastered.length>=total;
  return `<section class="screen extra-screen"><div class="extra-body deck-body"><header class="extra-header"><button class="plain-btn" data-action="nav" data-screen="reviewHub" aria-label="返回复习列表">${icon('back')}</button><h1 tabindex="-1">${t.title}</h1></header><div class="deck-finish"><div class="deck-finish-bird">${bird('celebrate')}</div><h2>${all?'这一组，全记住了！':'这一轮，复习完成！'}</h2><p>${all?'下次用到，可以直接开口。':'不熟的词会留在牌堆里，再来一轮就好。'}</p><div class="deck-stats"><span>已掌握 <b>${mastered.length}</b> / ${total}</span><span>本轮 ${deck.round||1} 轮</span></div><div class="deck-finish-actions"><button class="button secondary" data-action="deck-again">再来一轮${icon('review')}</button><button class="button" data-action="nav" data-screen="reviewHub">返回复习${icon('arrow')}</button></div></div></div></section>`;
 }
 const term=t.terms[deck.index];
 const known=mastered.includes(term.en);
 return `<section class="screen extra-screen"><div class="extra-body deck-body"><header class="extra-header"><button class="plain-btn" data-action="nav" data-screen="reviewHub" aria-label="返回复习列表">${icon('back')}</button><h1 tabindex="-1">${t.title}</h1><span class="deck-counter">${deck.index+1} / ${total}</span></header><div class="deck-progress"><i style="width:${Math.round((deck.index+1)/total*100)}%"></i></div><button class="flashcard ${deck.revealed?'revealed':''}" data-action="reveal" aria-label="翻转词卡"><span class="flashcard-tag">${known?'已掌握':'还没掌握'}</span><span class="flashcard-en">${term.en}</span><span class="flashcard-cn ${deck.revealed?'':'muted'}">${deck.revealed?term.cn:'点一下，看中文'}</span><span class="flashcard-hint">${deck.revealed?'再点一下可以收起':'点卡片翻面'}</span></button><div class="deck-audio"><button class="button secondary" data-action="speak-term" data-text="${term.en.replace(/"/g,'&quot;')}">${icon('sound')}<span>听发音</span></button><span>${mastered.length} / ${total} 已掌握</span></div><div class="deck-actions">${deck.revealed?`<button class="button secondary" data-action="deck-next">还不熟${icon('review')}</button><button class="button" data-action="deck-master">${known?'再记一次':'记住了'}${icon('check')}</button>`:`<button class="button" data-action="reveal">看中文</button><button class="button secondary" data-action="deck-next">先跳过${icon('arrow')}</button>`}</div></div></section>`;
}

/* ---------------------------------------------------------------- achievements */
function achievementDefs(){
 return [
  {id:'streak',title:'一周不掉线',desc:'连续学习 7 天',icon:'flame',earned:saved.streak>=7,progress:saved.streak>=7?`已连续学习 ${saved.streak} 天`:`${Math.min(saved.streak,7)} / 7 天`},
  {id:'xp',title:'千分俱乐部',desc:'累计超过 1,000 XP',icon:'bolt',earned:saved.xp>=1000,progress:saved.xp>=1000?`累计 ${saved.xp.toLocaleString()} XP`:`${saved.xp.toLocaleString()} / 1,000 XP`},
  {id:'coffee',title:'咖啡自由',desc:'完成「点杯咖啡」',icon:'cup',earned:!!saved.completedLessons.coffee,progress:saved.completedLessons.coffee?'已完成':'完成点单课解锁'},
  {id:'directions',title:'问路达人',desc:'完成「问个方向」',icon:'compass',earned:!!saved.completedLessons.directions,progress:saved.completedLessons.directions?'已完成':'完成问路课解锁'},
  {id:'unit',title:'单元通关',desc:'完成咖啡店单元挑战',icon:'trophy',earned:!!saved.completedLessons.challenge,progress:saved.completedLessons.challenge?'已完成':'完成挑战解锁'}
 ];
}
function achievementModal(def){
 if(!def)return '';
 const action=def.earned?`<button class="button" data-action="share" data-id="${def.id}">${icon('share')}分享成就</button>`:`<button class="button" data-action="goto-lesson" data-id="${def.id}">${icon('arrow')}去完成这一步</button>`;
 return `<div class="modal-backdrop" data-action="close-modal"><div class="modal" role="dialog" aria-modal="true" aria-labelledby="ach-title" data-static="1"><div class="modal-icon">${icon(def.icon)}</div><span class="modal-status ${def.earned?'earned':''}">${def.earned?'已获得':'未解锁'}</span><h2 id="ach-title">${def.title}</h2><p>${def.desc}</p><div class="modal-progress">${def.progress}</div>${action}<button class="modal-close" data-action="close-modal">关闭</button></div></div>`;
}
function achievementsScreen(){
 const defs=achievementDefs();
 const earned=defs.filter(d=>d.earned).length;
 const items=defs.map(d=>`<button class="achievement ${d.earned?'earned':'locked'}" data-action="achievement" data-id="${d.id}"><span class="achievement-icon">${icon(d.icon)}</span><span class="achievement-info"><span class="achievement-title">${d.title}</span><span class="achievement-desc">${d.desc}</span><span class="achievement-progress">${d.progress}</span></span>${d.earned?`<span class="achievement-state">已获得</span>`:`<span class="achievement-state locked">待解锁</span>`}</button>`).join('');
 const modal=achievementModal(defs.find(d=>d.id===modalId));
 return `<section class="screen extra-screen"><div class="extra-body"><header class="extra-header"><button class="plain-btn" data-action="nav" data-screen="path" aria-label="返回学习路径">${icon('back')}</button><h1 tabindex="-1">成就</h1></header><div class="review-summary achievement-summary"><div class="review-summary-icon">${icon('trophy')}</div><div><strong>已解锁 ${earned} / ${defs.length} 枚徽章</strong><p>每一点进步都算数。</p></div><div class="review-ring" style="--pct:${Math.round(earned/defs.length*100)}"><span>${Math.round(earned/defs.length*100)}%</span></div></div><div class="achievement-list">${items}</div></div>${nav('achievements')}${modal}</section>`;
}

/* ---------------------------------------------------------------- profile */
function profileScreen(){
 const doneLessons=Object.values(saved.completedLessons).filter(Boolean).length;
 const totalLessons=Object.keys(saved.completedLessons).length;
 const mastered=totalMastered();
 const goalChips=[5,10,15,20].map(n=>`<button class="goal-chip ${saved.dailyGoal===n?'active':''}" data-action="set-goal" data-goal="${n}" aria-pressed="${saved.dailyGoal===n}">${n} 分钟</button>`).join('');
 const dailyMinutes=Math.min(saved.dailyGoal,Math.floor(saved.dailySeconds/60));
 return `<section class="screen extra-screen"><div class="extra-body"><header class="extra-header"><button class="plain-btn" data-action="nav" data-screen="path" aria-label="返回学习路径">${icon('back')}</button><h1 tabindex="-1">我的 Pip</h1></header><div class="profile-bird">${bird('wave')}</div><h2 class="profile-name">小林的学习日常</h2><div class="profile-detail"><span>正在学习</span><strong>英语 · 初级 A1</strong></div><div class="profile-detail"><span>累计经验</span><strong class="number">${saved.xp.toLocaleString()} XP</strong></div><div class="profile-detail"><span>连续学习</span><strong>${saved.streak} 天</strong></div><div class="profile-detail"><span>已完成关卡</span><strong>${doneLessons} / ${totalLessons}</strong></div><div class="profile-detail"><span>复习掌握</span><strong>${mastered} / ${totalTermCount}</strong></div><div class="goal-block"><div class="goal-head"><span>每天的目标</span><strong>${dailyMinutes} / ${saved.dailyGoal} 分钟</strong></div><div class="goal-chips">${goalChips}</div><p class="small-text">改变目标后，今日进度会按新目标重新计算。</p></div><div class="extra-bottom"><button class="button" data-action="nav" data-screen="path">回去学一点${icon('arrow')}</button></div></div>${nav('profile')}</section>`;
}

/* ---------------------------------------------------------------- render */
function render(){
 app.dataset.screen=screen;
 app.innerHTML=screen==='path'?pathScreen():screen==='quiz'?quizScreen():screen==='complete'?completeScreen():screen==='reviewHub'?reviewHubScreen():screen==='reviewDeck'?deckScreen():screen==='achievements'?achievementsScreen():screen==='profile'?profileScreen():pathScreen();
 if(screen==='quiz'&&saved.run){
  if(saved.run.animate){saved.run.animate=false;persist();}
  // Keep keyboard focus on the chosen answer after a rerender.
  requestAnimationFrame(()=>{
   if(saved.run?.selection&&!saved.run?.feedback){
    app.querySelector(`[data-word="${CSS.escape(saved.run.selection)}"]`)?.focus({preventScroll:true});
   }
  });
 }
}

/* ---------------------------------------------------------------- events */
function handleWord(word){
 if(!saved.run||saved.run.feedback)return;
 saved.run.selection=word;
 persist();
 render();
}
function checkAnswer(){
 const run=saved.run,q=currentQuestion();
 if(!run||!q||run.feedback||!run.selection)return;
 const source=app.querySelector('.word.selected')?.getBoundingClientRect();
 if(run.selection===q.answer){
  run.feedback='correct';run.animate=true;
  if(run.firstTry)run.correctFirstTry++;
  run.answered=Math.max(run.answered,run.qIndex+1);
  run.streak++;
  addLearningTime(30);
  if(soundOn)chirp();
 }else{
  run.feedback='wrong';run.streak=0;run.firstTry=false;
  saved.lives=Math.max(0,saved.lives-1);
  save();
 }
 render();
 if(run.feedback==='correct'&&source&&q.type==='fill'&&!reduceMotion()){
  const word=app.querySelector('.blank');const destination=word?.getBoundingClientRect();
  if(destination){
   word.animate([
    {transform:`translate(${source.x-destination.x}px, ${source.y-destination.y}px) rotate(0deg) scale(${source.width/destination.width}, ${source.height/destination.height})`},
    {transform:'translate(0, -3px) rotate(-4deg) scale(1.02)',offset:.82},
    {transform:'rotate(-3deg)'}
   ],{duration:360,easing:'cubic-bezier(.18,.75,.3,1)'});
  }
 }
}
function retryAnswer(){
 if(!saved.run)return;
 if(saved.lives===0){saved.lives=4;save();}
 saved.run.selection='';saved.run.feedback='';saved.run.animate=false;
 persist();render();
}
function nextQuestion(){
 const run=saved.run;
 if(!run||run.feedback!=='correct')return;
 const lesson=lessons[run.lessonId];
 if(run.qIndex<lesson.questions.length-1){
  run.qIndex++;run.selection='';run.feedback='';run.firstTry=true;run.animate=false;
  persist();
  screen='quiz';render();focusHeading();
 }else{
  finishRun();
 }
}
function leaveLesson(){
 stopAudio();
 persist();
 screen='path';render();focusHeading();
}
function markDeck(action){
 if(!deck)return;
 const t=reviewTopics[deck.topic];
 const term=t.terms[deck.index];
 if(action==='master'){
  const list=saved.reviewMastered[t.topic]||[];
  if(!list.includes(term.en)){saved.reviewMastered[t.topic]=[...list,term.en];save();}
  nextDeck();
 }else if(action==='next'){
  nextDeck();
 }else if(action==='again'){
  deck={...deck,index:0,revealed:false,done:false,round:(deck.round||1)+1};
  render();focusHeading();
 }
}
function nextDeck(){
 if(!deck)return;
 const t=reviewTopics[deck.topic];
 if(deck.index>=t.terms.length-1){
  deck={...deck,done:true,revealed:false};
 }else{
  deck={...deck,index:deck.index+1,revealed:false};
 }
 render();focusHeading();
}
function shareAchievement(id){
 const def=achievementDefs().find(d=>d.id===id);
 if(!def||!def.earned)return;
 const text=`我在 Pip 英语学习里解锁了「${def.title}」：${def.desc}。连续学习 ${saved.streak} 天，累计 ${saved.xp.toLocaleString()} XP。`;
 const fallback=()=>{
  try{
   const ta=document.createElement('textarea');ta.value=text;ta.style.position='fixed';ta.style.opacity='0';document.body.appendChild(ta);ta.select();document.execCommand('copy');ta.remove();toast('分享文案已复制到剪贴板。');
  }catch{toast('分享文案：'+text);}
 };
 if(navigator.share){
  navigator.share({title:'Pip 成就',text}).catch(()=>{});
 }else if(navigator.clipboard?.writeText){
  navigator.clipboard.writeText(text).then(()=>toast('分享文案已复制到剪贴板。')).catch(fallback);
 }else fallback();
}
function openAchievement(id){modalId=id;render();requestAnimationFrame(()=>app.querySelector('.modal .modal-close')?.focus({preventScroll:true}));}
function closeModal(){modalId=null;render();focusHeading();}
function setGoal(n){
 saved.dailyGoal=n;
 saved.dailySeconds=Math.min(saved.dailySeconds,n*60);
 save();render();focusHeading();toast(`每日目标已改为 ${n} 分钟。`);
}

app.addEventListener('click',event=>{
 const word=event.target.closest('[data-word]');
 if(word&&!word.disabled){handleWord(word.dataset.word);return;}
 const el=event.target.closest('[data-action]');
 if(!el)return;
 const action=el.dataset.action;
 if(action==='nav'){modalId=null;go(el.dataset.screen||'path');return;}
 if(action==='start-lesson'){startCurrentLesson();return;}
 if(action==='node'){
  const id=el.dataset.id,state=el.dataset.state;
  if(state==='locked'){
   if(id==='directions')toast('先完成「点杯咖啡」，就能解锁「问个方向」。');
   else toast('先完成「问个方向」，就能解锁单元挑战。');
   return;
  }
  if(id==='greeting'||id==='menu'){openDeck(id);return;}
  if(saved.completedLessons[id]){startLesson(id,'review');return;}
  startLesson(id,'lesson');return;
 }
 if(action==='leave'){leaveLesson();return;}
 if(action==='check'){checkAnswer();return;}
 if(action==='retry'){retryAnswer();return;}
 if(action==='next'){nextQuestion();return;}
 if(action==='sound'){
  soundOn=!soundOn;saved.soundOn=soundOn;save();
  el.setAttribute('aria-pressed',soundOn);
  el.setAttribute('aria-label',`${soundOn?'关闭':'开启'}答题音效`);
  el.innerHTML=icon(soundOn?'sound':'mute');
  if(soundOn)chirp();
  return;
 }
 if(action==='listen'){playQuestionAudio(el);return;}
 if(action==='finish-cta'){
  if(lastResult?.demo||lastResult?.mode==='review'){go('path');return;}
  if(lastResult?.allDone&&lastResult?.lessonId==='challenge'){modalId=null;go('achievements');return;}
  go('path');return;
 }
 if(action==='open-deck'){openDeck(el.dataset.topic);return;}
 if(action==='reveal'){if(deck){deck.revealed=!deck.revealed;render();requestAnimationFrame(()=>app.querySelector('.flashcard')?.focus({preventScroll:true}));}return;}
 if(action==='speak-term'){speak(el.dataset.text,el);return;}
 if(action==='deck-next'){markDeck('next');return;}
 if(action==='deck-master'){markDeck('master');return;}
 if(action==='deck-again'){markDeck('again');return;}
 if(action==='achievement'){openAchievement(el.dataset.id);return;}
 if(action==='share'){shareAchievement(el.dataset.id);return;}
 if(action==='goto-lesson'){modalId=null;const id=el.dataset.id;if(id==='coffee'){startLesson('coffee',saved.completedLessons.coffee?'review':'lesson');}else if(id==='directions'){startLesson('directions',saved.completedLessons.directions?'review':'lesson');}else if(id==='unit'){startLesson('challenge',saved.completedLessons.challenge?'review':'lesson');}else{go('path');}return;}
 if(action==='close-modal'){
  const inside=!!event.target.closest('.modal');
  if(inside&&!el.classList.contains('modal-close'))return;
  closeModal();return;
 }
 if(action==='set-goal'){setGoal(Number(el.dataset.goal));return;}
});

document.addEventListener('keydown',event=>{
 if(event.key!=='Escape')return;
 if(modalId){closeModal();return;}
 if(screen==='reviewDeck'){go('reviewHub');return;}
});

/* ---------------------------------------------------------------- demo URL state */
if(screen==='quiz'){
 if(!saved.run||saved.run.lessonId!=='coffee'||saved.run.awarded===true){
  saved.run=createRun('coffee','lesson');
 }
 if(params.get('state')==='correct'){
  saved.run.selection='milk';
  saved.run.feedback='correct';
  saved.run.animate=false;
  saved.run.firstTry=true;
  saved.run.correctFirstTry=1;
  saved.run.answered=1;
  saved.run.streak=1;
 }
}
if(screen==='complete'&&!lastResult){lastResult=demoResult();}
if(screen==='reviewDeck'){
 if(!deck)deck={topic:'coffee',index:0,revealed:false,done:false,round:1};
}
if(screen==='reviewHub'){/* no-op */}
if(!contentScreens.includes(screen))screen='path';

render();
if(screen==='path'){/* initial screen should not steal focus */}else{focusHeading();}
})();
