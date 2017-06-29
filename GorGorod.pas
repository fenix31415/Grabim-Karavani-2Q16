unit GorGorod;

interface
uses System.Collections.Generic,graphabc;
const
  isTomorrow = false;
  sp = #10;
  COUNT_HOMES = 7;
  COUNT_PLAYERS = 10;
  dot = '.';
  tab = #09;
  mark1 = '<';
  mark2 = '>';
  bdot = '•';
  PathCommHouses = 'Commands/CommHouses.txt';
  PathCommTrades = 'Commands/CommTrades.txt';
  PathCommGoes = 'Commands/CommGoes.txt';
  PathCommVoices = 'Commands/CommVoices.txt';
  WIDTH = 1440;
  WidRightCall=650;
  HEIGHT_First = 40;
  HEIGHT_SEC = 200;
  HEIGHT_FIRD = 250;
  HEIGHT_FOUR = 400;
  DIST = 10;
  Otst = 10;

function ishavesea(i:integer):boolean;
function getNameTown(i:integer):string;
function getNameRes(ind:integer):string;
function viewOut(x,y,w,h:integer;s:string;dist:integer):boolean;
function getHouseName(b,t,l:integer):string;
function viewOut(x,y,w,h:integer;s:string):boolean;

type

  WayNei = (N,S,E,W,O,nul);
  
  HouseEffects = (CanSeaTrade,CanAttack,BlessMars,BlessMinewr,BlessUp1,BlessUp2,BlessUp3,BlessUp4,BlessNept1,BlessNept2,BlessNept3,BlessNept4);

  Ress = class
  public 
    res: array[0..4] of integer;
    constructor Create();
    constructor Create(a1,a2,a3,a4,a5:integer);
    constructor Create(r:ress);
    begin
      for var i:=0 to 4 do
        self.res[i]:=r.res[i];
    end;
    class function operator+(a,b:Ress):Ress;
    begin
      result:=new Ress();
      for var i:= 0 to 4 do
        result.res[i]:=a.res[i]+b.res[i];
    end;
    class function operator-(a,b:Ress):Ress;
    begin
      result:=new Ress();
      for var i:= 0 to 4 do
        result.res[i]:=a.res[i]-b.res[i];
    end;
    class function operator-(a:Ress):Ress;
    begin
      result:=new Ress(-a.res[0],-a.res[1],-a.res[2],-a.res[3],-a.res[4]);
    end;
    function InMinus():boolean;
    begin
      result:=false;
      for var i:=0 to 4 do
        if(self.res[i]<0)then result:=true;
    end;
    class function operator/(a:ress;b:real):Ress;
    begin
      result:=new Ress(a);
      for var i:=0 to 4 do
        if(a.res[i]>0)then result.res[i]:=round(result.res[i]*b)else result.res[i]:=0;
    end;
    class function operator*(a:Ress;b:real):Ress;
    begin
      Result:=new Ress(round(a.res[0]*b),round(a.res[1]*b),round(a.res[2]*b),round(a.res[3]*b),round(a.res[4]*b));
    end;
    class function operator=(a,b:Ress):boolean;
    begin
      result:=true;
      for var i:=0 to 4 do
        if(a.res[i]<>b.res[i])then result:=false;
    end;
    function ToString(): string; override;
    function Print(c1,c2:char;withpl:boolean):string;
    begin
      if(withpl)then begin
        for var i:=0 to 4 do
          if(self.res[i]=0)then else
          if(self.res[i]>0)then result+=' +'+IntToStr(self.res[i])+''+getNameRes(i) else
            Result+=' -'+IntToStr(abs(self.res[i]))+''+getNameRes(i);
        if(result='')then begin
          exit;
        end;
        if(result[result.Length]=',')then result:=result.Substring(0,result.Length-1);
        result:=Trim(result);
        result:=c1+result;
        result+=c2;
      end else begin
        for var i:=0 to 4 do
          if(self.res[i]=0)then else
          if(self.res[i]>0)then result+=' '+IntToStr(self.res[i])+''+getNameRes(i) else
            Result+=' '+IntToStr(abs(self.res[i]))+''+getNameRes(i);
        if(result='')then begin
          exit;
        end;
        if(result[result.Length]=',')then result:=result.Substring(0,result.Length-1);
        result:=Trim(result);
        result:=c1+result;
        result+=c2;
        if(result='()')then result:='';
      end;
    end;
    function Print():string;
    begin
      result:=Print('(',')',true);
    end;

  end;

  Even = class
  public
    name:string;
    res:ress;
    chance:integer;
    constructor Create(name:string;res:Ress;cha:integer);
    begin
      self.name:=name;
      self.res:=new Ress(res);
      self.chance:=cha;
    end;
    constructor Create(e:Even);
    begin
      Create(e.name,e.res,e.chance);
    end;
    function Tostring():string;override;
  end;
  
  Nei = class
  public
    isKnown,isExist:boolean;
    num,fromreturn,isOnSea:integer;
    from:WayNei;
    money,heSteal,iSteal:Ress;
    heAttack,iAttack:boolean;
    constructor Create(fr:WayNei;num:integer);
    begin
      self.isExist:=false;
      self.from:=fr;
      self.fromreturn:=-1;
      self.money:=new Ress();
      self.heattack:=false;
      self.iattack:=false;
      self.isKnown:=false;
      if(fr=WayNei.O)then
        self.isOnSea:=1 else
        self.isOnSea:=0;
      self.num:=num;
      self.isteal:=new Ress();
      self.hesteal:=new Ress();
    end;
    constructor Create(fr:WayNei;num:integer;isExist:boolean);
    begin
      create(fr,num);
      self.isExist:=isExist;
    end;
    constructor Create(ne:Nei);
    begin
      create(ne.from,ne.num,ne.isExist);
    end;
  end;

  House = class
  public 
    branch, lvl, tupe: integer;
    profit:Ress;
    effects:List<HouseEffects>;
    isvorked:boolean;
    class function operator=(a,b:House):boolean;
    begin
      result:=(a.branch=b.branch)and(a.lvl=b.lvl)and(a.tupe=b.tupe);
    end;
    constructor Create(branch, tupe, lvl: integer);
    constructor Create();
    constructor Create(h:House);
    begin
      self.branch:=h.branch;
      self.lvl:=h.lvl;
      self.tupe:=h.tupe;
      self.effects:=new List<HouseEffects>();
      for var i:=0 to h.effects.COUNT-1 do
        self.effects.add(h.effects[i]);
      self.profit:=new Ress(h.profit);
    end;
    function ToString(): string; override;
    function Print():string;
    //function Plott():string;
  end;
  
var COSTATTACK,COSTGOCHECK,STARTUP:Ress;
  
///prost menaet. Nahalavy
function UpGradeHouse(var h1:house;h2:House):boolean;
function CanUpGrade(h1,h2:House):boolean;
function getHouseCost(b,t,l:integer):Ress;
function getHouseProfit(b,t,l:integer):Ress;
function StrToWay(s:string):WayNei;
function isRebr(x,y:integer):WayNei;
function GetUpGrades(h:house):list<House> ;
function getRebuilds(h:house):list<House>;

type
  Town = class
  public
    name: string;
    num:integer;
    village: array of House;
    offer,money,profit,houseprofit,portsprofit: Ress;
    Neis:Dictionary<WayNei,Nei>;
    OpenedNeis,CamesNeis,NothingNeis,SeaNeis:List<Nei>;
    OKs:list<integer>;
    //I;  he with I
    trades:array[0..1] of integer;
    profittrades:array[0..1] of Ress;
    currevents:List<even>;
    
    constructor Create(num:integer);
    function ToString(): string; override;
    function save(path: string): boolean;
    function Voise(e:even):boolean;
    begin
      self.currevents.Add(new Even(e));
      result:=true;
    end;
    ///ret house if exist and b.t.0 if else
    function MaxLvl(h:House):House;
    begin
      result:=new House(h);
      result.lvl:=0;
      if(h.lvl>1)then begin
        foreach i:House in self.village do
          if(i.branch=h.branch)and(i.tupe=h.tupe)and(i.lvl>result.lvl)then
            result.lvl:=i.lvl;
      end else begin
      //b.0.1
        foreach i:House in self.village do
          if(i.branch=h.branch)and(i.tupe=0)and(i.lvl=1)then begin
            result.lvl:=i.lvl;
            result.tupe:=0;
          end;
      end;
    end;
    function Update():boolean;
    begin
      foreach i:KeyValuePair<WayNei,Nei> in self.Neis do
        if(i.Value.fromreturn>1)then
          self.Neis[i.key].fromreturn-=1 else
        if(i.value.fromreturn=1)then begin
          self.Neis[i.Key].fromreturn:=-1;
          if not(i.Value.isExist)then begin
            self.NothingNeis.Add(new Nei(i.Value));
            self.Neis[i.Key].isKnown:=true;
          end else begin
            self.OpenedNeis.Add(new Nei(i.Value));
            self.Neis[i.Key].isKnown:=true;
          end;
        end;
      result:=true;
    end;
    function CanUpGrade_Another(h:House):boolean;
    begin
      result:=MaxLvl(h).lvl<=0;
    end;
    function UpGradeTown(h1,h2:House;ismustcheck:boolean):boolean;
    begin
      var ne:=self.money+self.profit-getHouseCost(h2.branch,h2.tupe,h2.lvl);
      if(ne.InMinus())then exit;
      
//      if(self.num=4)and(h2.branch=4)then
//        raise new System.Exception(h1.ToString+' '+h2.ToString);
        
      if(ismustcheck and not CanUpGrade_Another(h2))then begin
        result:=false;
        exit;
      end;
      if(ismustcheck)and(not CanUpGrade(h1,h2))then begin
        result:=false;
        exit;
      end;
      for var i:=0 to self.village.Length-1 do
        if(self.village[i]=h1)then begin
          if(h2.branch=6)and(ishavesea(self.num))then begin
            result:=UpGradeHouse(self.village[i],h2);
            if(result)then self.profit:=self.profit-gethousecost(h2.branch,h2.tupe,h2.lvl);
         end;
          if(h2.branch=6)and(not ishavesea(self.num))then result:=false;
          if(h2.branch<>6)then begin
            result:=UpGradeHouse(self.village[i],h2);
            if(result)then self.profit:=self.profit-gethousecost(h2.branch,h2.tupe,h2.lvl);
          end;
          exit;
        end;
    end;
    function ReBuildHouse(h1,h2:House):boolean;
    begin
      var ne:=self.money+self.profit-getHouseCost(h2.branch,h2.tupe,h2.lvl);
      if(ne.InMinus())then exit;
      if(h1.branch<>h2.branch)or(h1.lvl<>h2.lvl)then begin
        Result:=false;
        exit;
      end;
      result:=false;
      var i:integer;
      for i:=0 to self.village.Length-1 do
        if(self.village[i]=h1)then begin
          if(CanUpGrade_Another(h2))then begin
            result:=UpGradeHouse(self.village[i],h2);
            if(Result)then begin
              self.profit:=self.profit+getHouseCost(h2.branch,h2.tupe,h2.lvl);
              
            end;
          end;
          break;
        end;
    end;
    function UpGradeTown(h1,h2:House):boolean;
    begin
      result:=UpGradeTown(h1,h2,true);
    end;
    function isFavePort():boolean;
    begin
      result:=false;
      foreach i:House in self.village do
        if(i.branch=6)then result:=true;
    end;
    function BuildHouse(h:House):boolean;
    begin
      result:=false;
      var b:=(self.num=4)and(h.branch=2);
      if(h.lvl=1)then
        for var i:=0 to self.village.Length-1 do
          if(self.village[i].lvl=0)then begin
            result:=UpGradeTown(self.village[i],h);
            exit;
          end;
      var h1:=new House(h.branch,h.tupe,h.lvl-1);
      if(h.lvl=2)then h1.tupe:=0;
      result:=UpGradeTown(h1,h,false);
    end;
    function GoCheck(nap:WayNei):boolean;
    begin
      var ne:=self.money+self.profit-COSTGOCHECK;
      if(not ne.InMinus())then begin
        self.Neis[nap].fromreturn:=2;
        self.profit:=self.profit-COSTGOCHECK;
        result:=true;
      end;
    end;
    function Pay(res:ress):boolean;
    begin
      self.money:=self.money+res;
      result:=true;
    end;
    function DestroyHouse(h:house):boolean;
    begin
      var costdest:=getHouseCost(h.branch,h.tupe,h.lvl)*(2/3);
      var ne:=self.money+self.profit-costdest;
      if(ne.InMinus())then exit;
      self.profit:=self.profit-costdest;
      result:=true;
      for var i:=0 to self.village.Length-1 do
        if(self.village[i]=h)then begin
          self.village[i]:=new House(0,0,0);
          exit;
        end;
    end;
    function UpDateEvent(e:even):boolean;
    begin
      self.profit:=self.profit+e.res;
      result:=true;
    end;
    function PrintVillage():string;
    begin
      result:='';
      var haveEmtyField:boolean;
      foreach i:House in self.village do
        if(i.lvl>0)and(i.branch<>5)then begin
          var s:string;
          s:='';
          s:=i.Print();
          var ups:=GetUpGrades(i);
          if(i.lvl=1)then begin
            if(ups.Count=0)then else begin
              s+=sp+tab+'Улучшить до:'+sp;
              foreach ii:House in ups do
                if(MaxLvl(ii).lvl=0)then
                  s+=tab+mark1+getHouseCost(ii.branch,ii.tupe,ii.lvl).Print('{','}',false)+' '+ii.Print()+sp;
            end;
          end else begin
            if(ups.Count=0)then else begin
              s+=sp+tab+'Улучшить до:';
              foreach ii:House in ups do
                  s+=getHouseCost(ii.branch,ii.tupe,ii.lvl).Print('{','}',false)+' '+ii.Print();
            end;
            var rebs:=getrebuilds(i);
            var exsthomes:=new List<integer>();
            for var ii:=0 to rebs.Count-1 do
              if((MaxLvl(rebs[ii])).lvl>0)then
                exsthomes.Add(ii);
            foreach ii:integer in exsthomes do
              rebs.RemoveAt(ii);
            
            if(rebs.Count=0)then s+=sp else begin
              s+=sp+tab+'Перестроить в'+sp;
              foreach ii:House in rebs do
                s+=tab+mark1+(getHouseCost(ii.branch,ii.tupe,ii.lvl)*(2/3)).Print('{','}',false)+' '+ii.Print()+sp;
            end;
          end;
          
          result+=mark2+s+sp;
        end else haveEmtyField:=true;
        
      var canBuild:boolean:=false;
      foreach i:House in self.village do
        if(i.lvl=0)then
          canBuild:=true;
      if(haveEmtyField)and(canBuild)then begin
        
        
        var s:string;
        s:='';
        var i:=new House(0,0,0);
        s:=i.Print();
        var ups:=GetUpGrades(i);
        var exsthomes:=new List<integer>();
        for var ii:=0 to ups.Count-1 do
          if((MaxLvl(ups[ii])).lvl>0)then
            exsthomes.Add(ii);
        var qqtmp:=0;
        foreach ii:integer in exsthomes do begin
          ups.RemoveAt(ii-qqtmp);
          qqtmp+=1;
        end;
        
        
        
        s:=mark2+'Можно построить:'+sp;
        foreach ii:House in ups do
            if (ii.branch<>5) then
          s+=tab+mark1+getHouseCost(ii.branch,ii.tupe,ii.lvl).Print('{','}',false)+' '+ii.Print()+sp;
          s:=s.Substring(0,s.Length-1);

        result+=s;
      end;
      var qqtmp:=0;
      if(MaxLvl(new House(6,1,0)).lvl>0)then qqtmp+=1;
      if(MaxLvl(new House(6,2,0)).lvl>0)then qqtmp+=1;
      if(canBuild)and(haveEmtyField)and(ishavesea(self.num))and(qqtmp<=1)then result+=sp+mark1+getHouseCost(6,0,1).Print('{','}',false)+' '+(new House(6,0,1)).Print();
    end;
    function PrintEvents():string;
    begin
      result:='События:'+sp;
      foreach i:Even in currevents do
        result+=bdot+i.ToString()+sp;
        
      var counttrades:=0;
      for var i:=0 to 1 do
        if(self.trades[i]<>-1)then
          counttrades+=1;
      if(counttrades>0)then begin
        result+=bdot+'Обмен с:'+sp;
        for var i:=0 to 1 do
          if(self.trades[i]<>-1)then
            result+=mark2+getNameTown(self.trades[i])+' '+self.profittrades[i].Print()+sp;
      end;
      
      foreach i:KeyValuePair<WayNei,nei> in self.Neis do
        if(i.value.heattack)then begin
          if(i.Value.heSteal=new Ress())then
            result+=bdot+'Нападение '+getNameTown(i.Value.num)+' '+'безуспешно'+sp else
            result+=bdot+'Нападение '+getNameTown(i.Value.num)+' '+(-i.Value.hesteal).Print()+sp;
        end;
        
      foreach i:KeyValuePair<WayNei,nei> in self.Neis do
        if(i.value.iattack)then
          if(i.Value.iSteal=new Ress())then
            result+=bdot+'Нападение на '+getNameTown(i.Value.num)+' '+'безуспешно'+sp else
            result+=bdot+'Нападение на '+getNameTown(i.Value.num)+' '+i.Value.isteal.Print()+sp;
        
      
      if(self.CamesNeis.Count>0)then begin
        foreach i:Nei in self.CamesNeis do
          result+=bdot+'Прибыли послы поселения '+getNameTown(i.num)+'('+i.from.ToString()+')'+sp;
      end;
      
      if(self.OpenedNeis.Count>0)then begin
        foreach i:Nei in self.OpenedNeis do
          result+=bdot+'Вы обнаружили поселение '+getNameTown(i.num)+'('+i.from.ToString()+')'+sp;
      end;
      
      if(self.NothingNeis.Count>0)then begin
        foreach i:Nei in self.NothingNeis do
          result+=bdot+'Ваши послы не нашли поселений'+'('+i.from.ToString()+')'+sp;
      end;
    end;
    function PrintProfit():string;
    begin
      result:='Доход зданий:'+sp;
      var profmars:=MaxLvl(new House(5,1,0)).profit;
      var prof:=self.houseprofit+self.portsprofit-profmars;
      for var i:= 0 to 4 do
      begin
        if(prof.res[i]>0)then begin
          result+='+'+IntToStr(prof.res[i])+getNameRes(i)+sp;
        end;
        if(prof.res[i]<0)then begin
          result+=IntToStr(prof.res[i])+getNameRes(i)+sp;
        end;
        if(prof.res[i]=0)then begin
          result+=IntToStr(prof.res[i])+getNameRes(i)+sp;
        end;
      end;
    end;
    function PrintRess():string;
    begin
      result:='Ресурсы:'+sp;
      for var i:= 0 to 4 do
      begin
        if(money.res[i]>0)then begin
          result+=IntToStr(money.res[i])+getNameRes(i)+sp;
        end;
        if(money.res[i]<0)then begin
          result+=IntToStr(money.res[i])+getNameRes(i)+sp;
        end;
        if(money.res[i]=0)then begin
          result+=IntToStr(money.res[i])+getNameRes(i)+sp;
        end;
      end;
    end;
    function AddProfit():boolean;
    begin
      self.money:=self.money+self.profit;
      result:=true;
    end;
    function AddHouseProfit():boolean;
    begin
    //tut atstoi s odnovremennim check'om. nu i ladno
    var isrelax:boolean;
    repeat
      isrelax:=false;
      var currMoney:=self.money+self.profit;
      foreach var i:House in self.village do begin
        var isnorm:=true;
        for var ii:=0 to 4 do
          if((currMoney.res[ii]<0)and(i.profit.res[ii]<0))or((currMoney.res[ii]>=0)and(currMoney.res[ii]+i.profit.res[ii]<0))then isnorm:=false;
        if(isnorm)and( not i.isvorked)then begin
          self.profit:=self.profit+i.profit;
          if(i.branch<>6)then self.houseprofit:=self.houseprofit+i.profit else
          self.portsprofit:=self.portsprofit+i.profit;
          i.isvorked:=true;
          isrelax:=true
        end;
      end;
    until not isRelax;
      result:=true;
    end;
    function upDateEffects():boolean;
    begin
      foreach h:House in self.village do
        foreach ef:HouseEffects in h.effects do
          case ef of
            HouseEffects.BlessMars:begin
              
            end;
            HouseEffects.BlessMinewr:begin
              
            end;
            HouseEffects.BlessNept1:begin
              if(h.isvorked)then
                  self.profit:=self.profit+self.portsprofit/0.3;
            end;
            HouseEffects.BlessNept2:begin
              if(h.isvorked)then
                  self.profit:=self.profit+self.portsprofit/0.6;
            end;
            HouseEffects.BlessNept3:begin
              if(h.isvorked)then
                  self.profit:=self.profit+self.portsprofit/1.0;
            end;
            HouseEffects.BlessNept4:begin
              if(h.isvorked)then
                  self.profit:=self.profit+self.portsprofit/1.5;
            end;
            HouseEffects.BlessUp1:begin
              if(h.isvorked)then
                self.profit.res[0]:=self.profit.res[0]+round(self.houseprofit.res[0]*0.1+self.portsprofit.res[0]*0.1);
            end;
            HouseEffects.BlessUp2:begin
              if(h.isvorked)then
                self.profit.res[0]:=self.profit.res[0]+Round(self.houseprofit.res[0]*0.2+self.portsprofit.res[0]*0.2);
            end;
            HouseEffects.BlessUp3:begin
              if(h.isvorked)then
                self.profit.res[0]:=self.profit.res[0]+Round(self.houseprofit.res[0]*0.3+self.portsprofit.res[0]*0.3);
            end;
            HouseEffects.BlessUp4:begin
              if(h.isvorked)then
                self.profit.res[0]:=self.profit.res[0]+Round(self.houseprofit.res[0]*0.4+self.portsprofit.res[0]*0.4);
            end;
            HouseEffects.CanAttack:begin
              
            end;
            HouseEffects.CanSeaTrade:begin
              
            end;
          end;
      result:=true;
    end;
end;
  
function LoadRess(s: string): Ress;
function LoadHouse(s: string): House;
function LoadTown(s: string): Town;
function ReadTown(path:string):Town;
function GetProfit(b,t,l:integer):Ress;


var
  DataHouseNames:List<List<list<string>>>;
  DataHouseProfit,DataHouseCost:List<List<list<Ress>>>;
  DataEvents:List<Even>;

type
  Game = class
  public
    towns:array of Town;
    function GodVoise(name:integer;e:integer):boolean;
    begin
      self.towns[name].Voise(DataEvents[e]);
      result:=true;
    end;
    function Load(path:string):boolean;
    begin
      for var i:=0 to COUNT_PLAYERS-1 do
        self.towns[i]:=ReadTown(path+IntToStr(i)+'.txt');
      result:=true;
    end;
    function DestroyHouse(name:integer;h:House):boolean;
    begin
      result:=self.towns[name].DestroyHouse(h);
    end;
    function Pay(name:integer;Res:Ress):boolean;
    begin
      self.towns[name].Pay(res);
      result:=true;
    end;
    function BuildHouse(name:integer;h:House):boolean;
    begin
      Result:=self.towns[name].BuildHouse(h);
    end;
    function ReBuildHouse(name:integer;h1,h2:House):boolean;
    begin
      result:=self.towns[name].ReBuildHouse(h1,h2);
    end;
    function Attack(name1,name2:integer):boolean;
    begin
      var ne:=self.towns[name1].money+self.towns[name1].profit-COSTATTACK;
      if(ne.InMinus())then exit;
      self.towns[name1].profit:=self.towns[name1].profit-COSTATTACK;
      var q:boolean;
      q:=false;
      foreach i:KeyValuePair<WayNei,Nei> in self.towns[name1].Neis do
        if(not q)and((i.Value.num=name2)and(i.Value.from<>WayNei.nul)and(i.Value.from<>WayNei.O)and(i.Value.isExist)and(i.Value.isKnown))then begin
          foreach j:KeyValuePair<WayNei,Nei> in self.towns[name2].Neis do
            if(j.Value.isExist)and(j.Value.num=name1)then begin
              self.towns[name2].Neis[j.Key].heattack:=true;
            end;
          self.towns[name1].Neis[i.Value.from].iattack:=true;
          var h1,h2,hh1,hh2:House;
          h1:=new House(self.towns[name1].MaxLvl(new House(5,1,0)));
          h2:=new House(self.towns[name2].Maxlvl(new House(5,1,0)));
          hh1:=new House(self.towns[name1].Maxlvl(new House(2,1,0)));
          hh2:=new House(self.towns[name2].Maxlvl(new House(2,1,0)));
          if(h1.lvl>h2.lvl)or((h1.lvl=h2.lvl)and(hh1.lvl>hh2.lvl))then begin
            var mon2:=self.towns[name2].money+self.towns[name2].profit;
            var steal:=new Ress(mon2*(1/3));
            self.towns[name1].profit:=self.towns[name1].profit+steal;
            self.towns[name2].profit:=self.towns[name2].profit-steal;
            foreach j:KeyValuePair<WayNei,Nei> in self.towns[name2].Neis do
              if(j.Value.isExist)and(j.Value.num=name1)then begin
                self.towns[name2].Neis[j.Key].hesteal:=new Ress(steal);
                self.towns[name1].Neis[i.Key].isteal:=new Ress(steal);
              end;
          end;
          q:=true;
        end;
      result:=true;
    end;
    function GoCheck(name:integer;nap:WayNei):boolean;
    begin
      result:=self.towns[name].GoCheck(nap);
    end;
    function Offer(name:integer;res:Ress):boolean;
    begin
      self.towns[name].offer:=new Ress(res);
      result:=true;
    end;
    function OKOffer(name1,name2:integer):boolean;
    begin
      var new1,new2:Ress;
      new1:=self.towns[name1].money+self.towns[name2].offer+self.towns[name1].profit;
      new2:=self.towns[name2].money-self.towns[name2].offer+self.towns[name2].profit;
      if(isrebr(name1,name2)=WayNei.nul)then exit;
      if not(new1.InMinus())and not(new2.InMinus())then begin
        self.towns[name2].OKs.Add(name1);
        result:=true;
      end;
    end;
    constructor Create();
    begin
      SetLength(self.towns,COUNT_PLAYERS);
      for var i:=0 to COUNT_PLAYERS-1 do
        self.towns[i]:=new Town(i);
    end;
    function Trade(name1,name2:integer):boolean;
    begin
      var new1,new2:Ress;
      var res:Ress:=new Ress(self.towns[name1].offer);
      new1:=self.towns[name1].money+self.towns[name1].profit-res;
      new2:=self.towns[name2].money+self.towns[name2].profit+res;
      if (new1.InMinus())or (new2.InMinus())then exit;
      self.towns[name1].profit:=new1-self.towns[name1].money;
      self.towns[name2].profit:=new2-self.towns[name2].money;
      self.towns[name1].trades[0]:=name2;
      self.towns[name1].profittrades[0]:=-res;
      self.towns[name2].trades[1]:=name1;
      self.towns[name2].profittrades[1]:=new Ress(res);
      result:=true;
    end;
    function addEvent(e:even):boolean;
    begin
      foreach var t:Town in self.towns do
        t.currevents.add(new Even(e));
      result:=true;
    end;
    function Update():boolean;
    begin
      var f:Text;
      var s:string;
      var param:list<string>;
      foreach var i:Town in self.towns do begin
        i.Update();
        foreach ne:Nei in i.OpenedNeis do begin
          foreach var neib:KeyValuePair<WayNei,Nei> in self.towns[ne.num].Neis do
            if(neib.Value.num=i.num)then begin
              self.towns[ne.num].Neis[neib.Value.from].isKnown:=true;
              self.towns[ne.num].CamesNeis.Add(neib.Value);
            end;
        end;
      end;

      {$region Voisec}
      Assign(f,PathCommVoices);
      Reset(f);
      while not(eof(f))do begin
        readln(f,s);
        param:=s.Split('/').ToList();
        if(param[0]='v')then begin
          self.GodVoise(StrToInt(param[1]),StrToInt(param[2]));
        end;
      end;
      close(f);
      {$endregion Voisec}
      
      {$region Events}
      foreach var t:Town in self.towns do begin
        foreach i:Even in DataEvents do
          if(Random(1,100)<=i.chance)then 
            t.currevents.Add(new Even(i));
        
       foreach e:even in t.currEvents do
         t.UpDateEvent(e);
      end;
      {$endregion Events}

      {$region Trade}
      Assign(f,PathCommTrades);
      Reset(f);
      
      while not(eof(f))do begin
        readln(f,s);
        param:=s.Split('/').ToList();
        if(param[0]='o')then begin
          self.Offer(StrToInt(param[1]),LoadRess(param[2]));
        end;
        if(param[0]='ok')then begin
          self.OKOffer(StrToInt(param[1]),StrToInt(param[2]));
        end;
      end;
      
      foreach i:Town in self.towns do begin
      
        var trader,sum:integer;
        trader:=-1;
        sum:=100000;
        foreach j:integer in i.OKs do
          if(self.towns[j].money.res[0]+self.towns[j].profit.res[0]<sum)then begin
            sum:=self.towns[j].money.res[0]+self.towns[j].profit.res[0];
            trader:=j;
          end;
          
        if(trader=-1)then else begin
          Trade(i.num,trader);
          i.offer:=new Ress();
        end;
      end;
      Close(f);
      {$endregion Trade}
      
      {$region Builds}
      Assign(f,PathCommHouses);
      Reset(f);
      while not(eof(f))do begin
        readln(f,s);
        param:=s.Split('/').ToList();
        if(param[0]='d')then begin
          self.DestroyHouse(StrToInt(param[1]),LoadHouse(param[2]));
        end;
        if(param[0]='b')then begin
          self.BuildHouse(StrToInt(param[1]),LoadHouse(param[2]));
        end;
        if(param[0]='r')then begin
          self.ReBuildHouse(StrToInt(param[1]),LoadHouse(param[2]),LoadHouse(param[3]));
        end;
      end;
      close(f);
      {$endregion Builds}
      
      {$region Goes}
      Assign(f,PathCommGoes);
      Reset(f);
      while not(eof(f))do begin
        readln(f,s);
        param:=s.Split('/').ToList();
        if(param[0]='a')then begin
          self.Attack(StrToInt(param[1]),StrToInt(param[2]));
        end;
        if(param[0]='g')then begin
          self.GoCheck(StrToInt(param[1]),StrToWay(param[2]));
        end;
      end;
      close(f);
      {$endregion Goes}

      {$region Profit}
      foreach var t:Town in self.towns do
        t.AddHouseProfit();
      {$endregion Profit}
      
      {$region Effects}
      foreach var t:Town in self.towns do
        t.upDateEffects();
      {$endregion Effects}
      
      foreach var t:Town in self.towns do begin
        t.AddProfit();
        for var i:=0 to 4 do
          if(t.money.res[i]<0)then t.money.res[i]:=0;
      end;
      
      result:=true;
    end;
    function PrintNeis(name:integer):string;
    begin
      var notknown:List<Nei>;
      notknown:=new List<Nei>();
      foreach i:KeyValuePair<WayNei,Nei> in self.towns[name].Neis do
        if(not i.value.isknown)then
          notknown.Add(new Nei(i.Value));
      if(notknown.Count>0)then begin
        result+='Не исследовано: ';
        foreach i:nei in notknown do
          result+=i.from.ToString()+', ';
        result:=result.Substring(0,result.Length-2);
        result+='.'+sp;
      end;
      
      var cantrade:list<Nei>;
      cantrade:=new List<Nei>();
      foreach i:KeyValuePair<WayNei,nei> in self.towns[name].Neis do
        if(i.value.isknown)and(i.value.isexist)then
          cantrade.Add(new Nei(i.Value));
      foreach i:Nei in self.towns[name].SeaNeis do
        if(i.isonsea=1)and(self.towns[i.num].MaxLvl(new House(6,2,0)).tupe=2)and(self.towns[name].MaxLvl(new House(6,2,0)).tupe=2)and(self.towns[i.num].MaxLvl(new House(6,2,0)).lvl>0)and(self.towns[name].MaxLvl(new House(6,2,0)).lvl>0)then
          //raise new System.Exception(self.towns[i.num].MaxLvl(new House(6,2,0)).ToString+i.num.ToString);
          cantrade.Add(new Nei(i));
      if(cantrade.Count>0)then begin
        result+='Можете торговать:'+sp;
        foreach i:Nei in cantrade do
          result+=mark2+getNameTown(i.num)+' ('+i.from.ToString()+')'+sp;
        result:=result.Substring(0,result.Length-1);
      end;
      if(cantrade.Count>0)then begin
        result+=sp;
        foreach i:Nei in cantrade do
          if not(self.towns[i.num].offer=new Ress())and(i.num<>name)then
            result+=getNameTown(i.num)+' предлагает обмен: '+self.towns[i.num].offer.Print()+sp;
      end;
    end;
    function Paint(path:string):boolean;
    begin
      MaximizeWindow();
      ClearWindow();
      foreach t:Town in self.towns do begin
        MaximizeWindow();
        ClearWindow();
        
        var x,y:integer;
        var txtout:string;
        var today:=System.DateTime.Today;
        //
        SetFontSize(16);
        SetPenWidth(2);
        //
        x:=WIDTH-WidRightCall;
        y:=HEIGHT_First;
        var data:=today;
        if(isTomorrow)then
          data:=data.AddDays(1);
        txtout:='Дата: '+data.ToString('d');
        viewOut(x,0,WidRightCall,HEIGHT_First,txtout);
        line(WIDTH,0,WIDTH,WindowHeight());
        line(x,0,x,WindowHeight());
        line(0,HEIGHT_First,WIDTH,HEIGHT_First);
        //line(2,0,2,WindowHeight());
        
        SetFontSize(19);
        txtout:='~'+t.name+'~';
        viewOut(0,0,x,HEIGHT_First,txtout);
        
        SetFontSize(15);
        txtout:=PrintNeis(t.num);
        x:=WIDTH-WidRightCall;
        y:=HEIGHT_First;
        //viewout(x+dist,y+dist,WidRightCall,TextHeight(txtout)+10,txtout);
        //viewOut(x,y,WidRightCall,HEIGHT_SEC,txtout,dist);
        TextOut(x+dist,y+dist,txtout);
        SetFontSize(16);
        
        y+=HEIGHT_SEC;
        line(x,y,WIDTH,y);
        
        txtout:=t.PrintEvents();
        //viewOut(x,y,WidRightCall,HEIGHT_FIRD,txtout,DIST);
        textout(x+dist,y+dist,txtout);
        y+=HEIGHT_FIRD;
        line(x,y,WIDTH,y);
        
        txtout:=t.PrintProfit();
        //viewOut(x+dist,y,WidRightCall div 2,HEIGHT_FOUR,txtout,dist);
        TextOut(x+dist,y+dist,txtout);
        line(x+WidRightCall div 2,y,x+WidRightCall div 2,y+HEIGHT_FOUR);
        txtout:=t.PrintRess();
        //viewOut(x + dist + WidRightCall div 2,y,WidRightCall div 2,HEIGHT_FOUR,txtout,dist);
        textout(x+dist+WidRightCall div 2,y+dist,txtout);
        y+=HEIGHT_FOUR;
        SetFontSize(12);
        line(0,y-110,WIDTH,y-110);
        
        
        x:=10;
        y:=10+HEIGHT_First;
        SetFontSize(9);
        txtout:=t.PrintVillage();
        textout(x+Otst,y,txtout);
        
        {txtout:=PrintNeis(t.num);
        x:=WIDTH-WidRightCall;
        y:=HEIGHT_First+2;
        viewout(x,y,WidRightCall,TextHeight(txtout)+10,txtout);
        y+=HEIGHT_SEC;
        line(x,y,WIDTH,y);
        
        y+=2;
        txtout:=t.PrintEvents();
        viewOut(x,y,WidRightCall,HEIGHT_First,txtout);
        y+=HEIGHT_FIRD;
        line(x,y,WIDTH,y);
        
        y+=2;
        txtout:=t.PrintProfit();
        viewOut(x,y,WidRightCall,HEIGHT_FOUR,txtout);
        y+=HEIGHT_FOUR;
        line(x,y,WIDTH,y);
        
        y+=2;
        txtout:=t.PrintRess();
        viewOut(x,y,WidRightCall,TextHeight(txtout)+10,txtout);
        
        x:=10;
        y:=10+HEIGHT_First;
        txtout:=t.PrintVillage();
        textout(x,y,txtout);}
        
        SaveWindow(path+IntToStr(t.num)+'.png');
        
      end;
      result:=true;
    end;
    function save(path:string):boolean;
    begin
      foreach t:Town in self.towns do
        t.save(path+IntToStr(t.num)+'.txt');
      result:=true;
    end;
  
  end;

implementation

function viewOut(x,y,w,h:integer;s:string;dist:integer):boolean;
begin
  TextOut(x+(w-TextWidth(s))div 2,y+dist,s);
  result:=true;
end;
function viewOut(x,y,w,h:integer;s:string):boolean;
begin
  TextOut(x+(w-TextWidth(s))div 2,y+(h-TextHeight(s)) div 2,s);
  result:=true;
end;
function StrToWay(s:string):WayNei;
begin
  if(s='e')then result:=WayNei.E;
  if(s='w')then result:=WayNei.W;
  if(s='s')then result:=WayNei.S;
  if(s='n')then result:=WayNei.N;
end;
function BoolToStr(b:boolean):string;
begin
  if(b)then result:='1' else result:='0';
end;
function StrToBool(s:string):boolean;
begin
  if(s='1')then result:=true else result:=false;
end;
function Even.Tostring():string;
begin
  result:=self.name+' '+self.res.Print();
end;
function getRebuilds(h:house):list<House>;
begin
  result:=new List<House>();
  if(h.lvl<=1)then exit;
  if(h.lvl=5)then begin
    
    exit;
  end;
  if(h.branch=1)or(h.branch=3)or(h.branch=4)then begin
    if(h.lvl>=2)and(h.lvl<=4)then begin
      if(h.tupe<>1)then
        result.Add(new House(h.branch,1,h.lvl));
      if(h.tupe<>2)then
        result.Add(new House(h.branch,2,h.lvl));
      if(h.tupe<>3)then
        result.Add(new House(h.branch,3,h.lvl));
    end;
    if(h.lvl=5)then begin
      if(h.tupe<>1)then
        result.Add(new House(h.branch,1,h.lvl));
      if(h.tupe<>3)then
        result.Add(new House(h.branch,3,h.lvl));
    end;
  end;
  if(h.branch=0)and(h.lvl>=2)then begin
    if(h.tupe<>1)then
      result.Add(new House(h.branch,1,h.lvl));
    if(h.tupe<>2)then
      result.Add(new House(h.branch,2,h.lvl));
  end;
  if(h.branch=2)then begin
    if(h.tupe<>1)then
      result.Add(new House(h.branch,1,h.lvl));
    if(h.tupe<>2)then
      result.Add(new House(h.branch,2,h.lvl));
    if(h.tupe<>3)then
      result.Add(new House(h.branch,3,h.lvl));
    if(h.tupe<>4)then
      result.Add(new House(h.branch,4,h.lvl));
  end;
  if(h.lvl<=2)and(h.branch=6)then begin
    if(h.tupe<>1)then
      result.Add(new House(h.branch,1,h.lvl));
    if(h.tupe<>2)then
      result.Add(new House(h.branch,2,h.lvl));
  end;
end;
function HFtoString(e:HouseEffects):string ;
begin
  case e of
    HouseEffects.BlessMars:result:='Благословение Марса';
    HouseEffects.BlessMinewr:result:='Благ. Минервы';
    HouseEffects.BlessUp1:result:='+10% к доходу динариев';
    HouseEffects.BlessUp2:result:='+20% к доходу динариев';
    HouseEffects.BlessUp3:result:='+30% к доходу динариев';
    HouseEffects.BlessUp4:result:='+40% к доходу динариев';
    HouseEffects.BlessNept1:result:='+30% к доходу портов';
    HouseEffects.BlessNept2:result:='+60% к доходу портов';
    HouseEffects.BlessNept3:result:='+100% к доходу портов';
    HouseEffects.BlessNept4:result:='+150% к доходу портов';
    HouseEffects.CanAttack:result:='Позволяет воевать';
    HouseEffects.CanSeaTrade:result:='Позволяет торговать по морю';
  end;
end;

function House.Print():string;
begin
  result:=getHouseName(self.branch,self.tupe,self.lvl)+' '+self.profit.Print();
  result:=result.Substring(0,result.Length-1);
  if(self.effects.Count=0)then result+=')' else begin
    result+='; ';
    foreach i:HouseEffects in self.effects do
      result:=result+Hftostring(i)+'; ';
    result:=result.Substring(0,result.Length-2);
    result+=')';
  end;
end;
function getNameRes(ind:integer):string;
begin
  case ind of
    0:result:='д';
    1:result:='м';
    2:result:='б';
    3:result:='е';
    4:result:='п';
  end;
end;
function initData(params a:array of string):boolean;
begin
  var f:text;
  var s:string;
  var inp:string;
  var param:List<string>;
  
  COSTATTACK := new Ress(200,0,2,1,0);
  COSTGOCHECK :=new Ress(0,0,0,0,0);
  STARTUP:=new Ress(1000,200,0,0,0);
  
  {$region HouseName}
  s:=a[0];
  Assign(f,s);
  Reset(f);
  DataHouseNames:=new List<List<List<string>>>();
  for var i:=0 to 6 do begin
    DataHouseNames.Add(new List<List<string>>());
    for var j:=0 to 4 do begin
      DataHouseNames[i].Add(new List<string>());
      for var k:=0 to 5 do
        DataHouseNames[i][j].Add('-');
    end;
  end;
  
  for var x:=0 to 6 do begin
    readln(f,inp);
    DataHouseNames[x][0][1]:=inp;
    for var z:=2 to 5 do begin
      readln(f,inp);
      param:=inp.Split('/').ToList();
      for var y:=0 to 3 do
        DataHouseNames[x][y+1][z]:=param[y];
    end;
  end;
  close(f);
  {$endregion HouseName}
  
  {$region HouseProfit}
  s:=a[1];
  Assign(f,s);
  Reset(f);
  DataHouseProfit:=new List<List<List<Ress>>>();
  for var i:=0 to 6 do begin
    DataHouseProfit.Add(new List<List<Ress>>());
    for var j:=0 to 4 do begin
      DataHouseProfit[i].Add(new List<Ress>());
      for var k:=0 to 5 do
        DataHouseProfit[i][j].Add(new Ress());
    end;
  end;
  
  for var x:=0 to 6 do begin
    readln(f,inp);
    DataHouseProfit[x][0][1]:=LoadRess(inp);
    for var z:=2 to 5 do begin
      readln(f,inp);
      param:=inp.Split('/').ToList();
      for var y:=0 to 3 do
        DataHouseProfit[x][y+1][z]:=LoadRess(param[y]);
    end;
  end;
  close(f);
  {$endregion HouseProfit}
  
  {$region HouseCost}
  s:=a[2];
  Assign(f,s);
  Reset(f);
  DataHouseCost:=new List<List<List<Ress>>>();
  for var i:=0 to 6 do begin
    DataHouseCost.Add(new List<List<Ress>>());
    for var j:=0 to 4 do begin
      DataHouseCost[i].Add(new List<Ress>());
      for var k:=0 to 5 do
        DataHouseCost[i][j].Add(new Ress());
    end;
  end;
  
  for var x:=0 to 6 do begin
    readln(f,inp);
    DataHouseCost[x][0][1]:=LoadRess(inp);
    for var z:=2 to 5 do begin
      readln(f,inp);
      param:=inp.Split('/').ToList();
      for var y:=0 to 3 do
        DataHouseCost[x][y+1][z]:=LoadRess(param[y]);
    end;
  end;
  close(f);
  {$endregion HouseCost}
  
  {$region Events}
  s:=a[3];
  Assign(f,s);
  Reset(f);
  DataEvents:=new List<Even>();
  s:=f.ReadToEnd();
  s:=s.Trim();
  param:=s.Split(sp).ToList();
  foreach i:string in param do begin
    if(i='')or(i=sp)then else begin
      var args:=i.Split('/').ToArray();
      var ev:Even;
      ev:=new Even(args[1],LoadRess(args[2]),strtoint(args[0]));
      DataEvents.Add(ev);
    end;
  end;
  close(f);
  {$endregion Events}
  
  result:=true;
end;
function getHouseCost(b,t,l:integer):Ress;
begin
  result:=new Ress(DataHouseCost[b][t][l]);
end;
function getHouseName(b,t,l:integer):string;
begin
  result:=DataHouseNames[b][t][l];
end;
function getHouseProfit(b,t,l:integer):Ress;
begin
  result:=new Ress(DataHouseProfit[b][t][l]);
end;
function getEffects(b,t,l:integer):List<HouseEffects>;
begin
  result:=new List<HouseEffects>();
  if(b=2)then
  begin
    if(l=5)then begin
      Result.Add(HouseEffects.BlessMinewr);
      Result.Add(HouseEffects.BlessUp4);
      Result.Add(HouseEffects.BlessNept4);
      exit;
    end;
    
    if(t=1)then Result.Add(HouseEffects.BlessMars);
    if(t=2)then Result.Add(HouseEffects.BlessMinewr);
    if(t=3)then
      if(l=2)then Result.Add(HouseEffects.BlessUp1)
      else if(l=3)then Result.Add(HouseEffects.BlessUp2)
      else if(l=4)then Result.Add(HouseEffects.BlessUp3)
      else Result.Add(HouseEffects.BlessUp4);
    if(t=4)then
      if(l=2)then Result.Add(HouseEffects.BlessNept1)
      else if(l=3)then Result.Add(HouseEffects.BlessNept2)
      else if(l=4)then Result.Add(HouseEffects.BlessNept3)
      else Result.Add(HouseEffects.BlessNept4);
  end;
  if(b=5)then Result.Add(HouseEffects.CanAttack);
  if(b=6)and(t=2)and(l>=2)then Result.Add(HouseEffects.CanSeaTrade);
end;
function isRebr(x,y:integer):WayNei;
begin
  if (((x=0) and (y=2))or((x=1)and(y=3))or((x=3)and(y=2))or((x=4)and(y=7))or((x=6)and(y=7))or((x=7)and(y=5))) then result:=WayNei.E else
  if (((x=0)and(y=1))or((x=2)and(y=3))or((x=3)and(y=1))or((x=5)and(y=7))or((x=7)and(y=6))or((x=8)and(y=7))) then result:=WayNei.W else
  if (((x=1)and(y=0))or((x=2)and(y=0))or((x=4)and(y=1))or((x=5)and(y=3))or((x=6)and(y=4))or((x=7)and(y=4))or((x=8)and(y=5))) then result:=WayNei.S else
  if ((x=1)and(y=4))or((x=3)and(y=5))or((x=4)and(y=6))or((x=5)and(y=8))or((x=7)and(y=8)) then result:=WayNei.N else
  if (((x=0)or(x=6)or(x=8)or(x=9)) and ((y=0)or(y=6)or(y=8)or(y=9)) and (x<>y)) then result:=WayNei.O else
  result:=WayNei.nul;
end;
function ishavesea(i:integer):boolean ;
begin
  if(i=0)then result:=true else
  if(i=6)then result:=true else
  if(i=8)then result:=true else
  if(i=9)then result:=true else
  result:=false;
end;
function getNameTown(i:integer):string;
begin
  if(i=0)then result:='Массилия' else
  if(i=1)then result:='Герговия' else
  if(i=2)then result:='Медиоланум' else
  if(i=3)then result:='Бибракта' else
  if(i=4)then result:='Ценабум' else
  if(i=5)then result:='Амальфи' else
  if(i=6)then result:='Юлиобона' else
  if(i=7)then result:='Неметоцена' else
  if(i=8)then result:='Флев' else
  if(i=9)then result:='Камулодун' else
  result:='GorGorD';
end;
constructor Ress.Create();
begin
  for var i:=0 to 4 do
    self.res[i]:=0;
end;
constructor House.Create(branch, tupe, lvl: integer);
begin
  self.branch := branch;
  self.lvl := lvl;
  self.tupe := tupe;
  self.effects:=new List<HouseEffects>(getEffects(branch,tupe,lvl));
  self.profit:=new Ress(GetProfit(branch,tupe,lvl));
end;
constructor House.Create();
begin
  self.branch := 0;
  self.lvl := 0;
  self.tupe := 0;
  self.effects:=new List<HouseEffects>();
  self.profit:=new Ress();
end;
constructor Town.Create(num:integer);
begin
  self.OpenedNeis:=new List<Nei>();
  self.NothingNeis:=new List<Nei>();
  self.CamesNeis:=new List<Nei>();
  self.portsprofit:=new Ress();
  self.houseprofit:=new Ress();
  self.trades[0]:=-1;
  self.trades[1]:=-1;
  self.currevents:=new List<Even>();
  self.OKs:=new List<integer>();
  self.name := getNameTown(num);
  self.num:=num;
  self.offer := new Ress();
  SetLength(self.village, COUNT_HOMES);
  for var i := 0 to self.village.Length - 1 do 
  begin
    self.village[i] := new House();
  end;
  self.village[0]:=new House(0,0,1);
  self.Neis:=new Dictionary<WayNei,Nei>();
  self.SeaNeis:=new List<Nei>();
    self.Neis.Add(WayNei.N,new Nei(WayNei.N,-1,false));
    self.Neis.Add(WayNei.S,new Nei(WayNei.S,-1,false));
    self.Neis.Add(WayNei.W,new Nei(WayNei.W,-1,false));
    self.Neis.Add(WayNei.E,new Nei(WayNei.E,-1,false));
  for var i:=0 to COUNT_PLAYERS-1 do begin
    if(i=self.num)then continue;
    var Way:=isrebr(num,i);
    if(way<>WayNei.nul)and(way<>WayNei.O)then
      self.Neis[way]:=new Nei(way,i,true) else
    if(way=WayNei.O)then self.SeaNeis.Add(new Nei(way,i));
  end;
  self.money:=new Ress();
  self.profit:=new Ress();
end;
constructor Ress.Create(a1,a2,a3,a4,a5:integer);
begin
  self.res[0]:=a1;
  self.res[1]:=a2;
  self.res[2]:=a3;
  self.res[3]:=a4;
  self.res[4]:=a5;
end;
function Town.ToString(): string;
begin
  var s := '';
  for var i := 0 to self.village.Length - 1 do 
  begin
    s := s + self.village[i].ToString() + sp;
  end;
  Result := self.num + sp + offer.ToString() + sp + money.ToString() + sp + s;
  s:=IntToStr(self.Neis[WayNei.N].fromreturn)+' ';
  s+=IntToStr(self.Neis[WayNei.S].fromreturn)+' ';
  s+=IntToStr(self.Neis[WayNei.W].fromreturn)+' ';
  s+=IntToStr(self.Neis[WayNei.E].fromreturn);
  result+=s;
  s:=sp;
  s+=booltostr(self.Neis[WayNei.N].isKnown)+' ';
  s+=booltostr(self.Neis[WayNei.S].isKnown)+' ';
  s+=booltostr(self.Neis[WayNei.W].isKnown)+' ';
  s+=booltostr(self.Neis[WayNei.E].isKnown);
  result+=s;
end;
function House.ToString(): string;
begin
  result := self.branch + dot + self.tupe + dot + self.lvl;
end;
function Ress.ToString(): string;
begin
  Result := self.res[0] + dot + self.res[1] + dot + self.res[2] + dot + self.res[3] + dot + self.res[4];
end;
function Town.save(path: string): boolean;
begin
  var f: text;
  Assign(f, path);
  Rewrite(f);
  write(f, self.ToString());
  Close(f);
  Result:=true;
end;
function ReadTown(path:string):Town;
begin
  var f:Text;
  assign(f,path);
  reset(f);
  result:=LoadTown(f.ReadToEnd);
  Close(f);
end;
function LoadRess(s: string): Ress;
begin
  var a:=s.Split(dot).Select(x->StrToInt(x)).ToList();
  result:=new Ress(a[0],a[1],a[2],a[3],a[4]);
end;
function LoadHouse(s: string): House;
begin
  var agrs := s.Split(dot).Select(x -> StrToInt(x)).ToArray();
  Result := new House(agrs[0],agrs[1],agrs[2]);
end;
function LoadTown(s: string): Town;
begin
  var args:=s.Split(sp);
  Result:=new Town(StrToInt(args[0]));
  Result.offer:=LoadRess(args[1]);
  Result.money:=LoadRess(args[2]);
  for var i:= 0 to COUNT_HOMES-1 do
    Result.village[i]:=LoadHouse(args[3+i]);
  var agrs:=args[3+7].Split(' ').Select(x->StrToInt(x)).ToArray();
  Result.Neis[WayNei.N].fromreturn:=agrs[0];
  Result.Neis[WayNei.S].fromreturn:=agrs[1];
  Result.Neis[WayNei.W].fromreturn:=agrs[2];
  Result.Neis[WayNei.E].fromreturn:=agrs[3];
  var ag:=args[4+7].Split(' ').Select(x->StrTobool(x)).ToArray();
  result.Neis[WayNei.N].isKnown:=ag[0];
  result.Neis[WayNei.S].isKnown:=ag[1];
  result.Neis[WayNei.W].isKnown:=ag[2];
  result.Neis[WayNei.E].isKnown:=ag[3];
end;
function GetProfit(b,t,l:integer):Ress;
begin
  Result:=new Ress(DataHouseProfit[b][t][l]);
end;
function CanUpGrade(h1,h2:House):boolean;
begin
  Result:=false;
  //build
  if(h1.lvl=0)and(h2.lvl=1)and(h2.tupe=0)then result:=true else
  //upgrade
  if(h1.lvl=1)and(h2.lvl=2)and(h1.tupe=0)and(h1.branch=h2.branch)then result:=true else
  if(h1.branch=h2.branch)and(h1.tupe=h2.tupe)and(h1.lvl+1=h2.tupe)then Result:=true else
  
  Result:=false;
end;
function UpGradeHouse(var h1:house;h2:house):boolean;
begin
  h1:=new House(h2);
  result:=true;
end;
function GetCostUpGrade(b,t,l:integer):Ress ;
begin
  result:=new Ress(DataHouseCost[b][t][l]);
end;
function GetUpGrades(h:house):list<House> ;
begin
  result:=new List<House>();
  if(h=new House(0,0,0))then begin
    for var i:=1 to 5 do
      result.Add(new House(i,0,1));
    exit;
  end;
  //upgrade
  if(h.lvl=1)and(h.tupe=0)then begin
    if(h.branch=2)then
      for var i:=1 to 4 do
        result.Add(new House(h.branch,i,2));
    if(h.branch=1)or(h.branch=4)or(h.branch=3)then
      for var i:=1 to 3 do
        result.Add(new House(h.branch,i,2));
    if(h.branch=5)then
      for var i:=1 to 1 do
        result.Add(new House(h.branch,i,2));
    if(h.branch=6)then
      for var i:=1 to 2 do
        result.Add(new House(h.branch,i,2));
    if(h.branch=0)then
      for var i:= 1 to 2 do
        Result.Add(new House(h.branch,i,2));
  end;
  if(h.lvl=2)or(h.lvl=3)and not((h.branch=6)and(h.tupe=1)and(h.lvl=3))then
    result.Add(new House(h.branch,h.tupe,h.lvl+1));
  if(h=new House(4,2,4))or(h=new House(3,1,4))or(h=new House(3,3,4))or((h.branch=2)and(h.lvl=4))then
    Result.Add(new House(h.branch,h.tupe,h.lvl+1));
end;

initialization
  initData('Data/DataHousesName.txt','Data/DataHousesProfit.txt','Data/DataHousesCost.txt','Data/DataEvents.txt','Commands/CommVoices.txt');
finalization
end.