uses GorGorod;

var otlad:Text;
    rim:game;

function DoItPlS(day:integer):boolean;
begin
  rim.Load('SAVES/day '+IntToStr(day-1)+'/saves/');
  rim.Update();
  rim.Paint('SAVES/day '+IntToStr(day)+'/screens/');
  rim.save('SAVES/day '+IntToStr(day)+'/saves/');
  result:=true;
end;

begin
  rim:=new Game();
  
  {$region Tests}
  Assign(otlad,'out.txt');
  rewrite(otlad);
  
  close(otlad);
  {$endregion Tests}
  
  DoItPlS(22);
  
  halt;
end.