(*
 *  The Battle Ship Game.
 *  Copyright (C) 2002  Kolia Morev <kolia39@mail.ru>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)


{$UNDEF DEBUG}

program sea_battle;
uses crt;

{ картинки }
{$I ansi\field_fr.pas}
{$I ansi\messagep.pas}
{$I ansi\a.pas}
{$I ansi\b.pas}
{$I ansi\c.pas}
{$I ansi\d.pas}
{$I ansi\e.pas}
{$I ansi\f.pas}
{$I ansi\g.pas}
{$I ansi\h.pas}

const
   numOfCells = 10;            { размерность игрового поля }
   numOfShips = 10; { количество кораблей у каждого игрока }
   maxShip = 4;      { максимально возможная длина корабля }

type
   tCell = (O, X);          { содержимое ячейки: незакрашено, закрашено }
   tShipType = (Ship1, Ship2, Ship3, Ship4);
                                    { типы кораблей по количеству палуб }
   tPlayer = (plHuman, plComp);            { игроки: человек, компьютер }

   tShipOnField = record
                     x,y: integer;
                     sindex: integer;
                  end;          { описание корабля игрока:
                                  координаты левого верхнего угла,
                                  номер корабля в массиве всех кораблей }
   tShipIndex = record
                   index, num, varnum: integer;
                end;            { описание типов кораблей:
                                  номер первого корабля данного типа
                                  в массиве всех кораблей, количество
                                  кораблей данного типа у каждого игрока,
                                  количество различных кораблей данного
                                  типа }

   tShip = array[1..maxShip,1..maxShip] of tCell; { описание формы корабля }
   tShipsField = array[1..numOfShips] of tShipOnField; { все корабли игрока }
   tField = array[1..numOfCells,1..numOfCells] of tCell; { поле из ячеек }

   tGame = record
              hShips, cShips: tShipsField;
              hField, cField: tField;
              currPl: tPlayer;                    { игрок, который ходит }
           end;                                        { все данные игрЫ }
   tPlaceProc = procedure(var ship: tShipsField; k: integer; i: tShipType);

const
   Ships: array[Ship1..Ship4] of tShipIndex =
          ((index: 1;  num: 4; varnum: 1),
           (index: 2;  num: 3; varnum: 2),
           (index: 4;  num: 2; varnum: 6),
           (index: 10; num: 1; varnum: 19)); { описание типов кораблей }
   shipMaps: array[1..28] of tShip =   { формы всех различных кораблей }
{1}        (((X,O,O,O),
             (O,O,O,O),
             (O,O,O,O),
             (O,O,O,O)),
{2}         ((X,X,O,O),
             (O,O,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,O,O,O),
             (X,O,O,O),
             (O,O,O,O),
             (O,O,O,O)),
{3}         ((X,X,X,O),
             (O,O,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,O,O,O),
             (X,O,O,O),
             (X,O,O,O),
             (O,O,O,O)),
            ((X,X,O,O),
             (O,X,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,O,O,O),
             (X,X,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,X,O,O),
             (X,O,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((O,X,O,O),
             (X,X,O,O),
             (O,O,O,O),
             (O,O,O,O)),
{4}         ((X,X,X,X),
             (O,O,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,O,O,O),
             (X,O,O,O),
             (X,O,O,O),
             (X,O,O,O)),
            ((X,X,X,O),
             (O,O,X,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,O,O,O),
             (X,X,X,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,X,X,O),
             (X,O,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((O,O,X,O),
             (X,X,X,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,X,O,O),
             (X,O,O,O),
             (X,O,O,O),
             (O,O,O,O)),
            ((O,X,O,O),
             (O,X,O,O),
             (X,X,O,O),
             (O,O,O,O)),
            ((X,O,O,O),
             (X,O,O,O),
             (X,X,O,O),
             (O,O,O,O)),
            ((X,X,O,O),
             (O,X,O,O),
             (O,X,O,O),
             (O,O,O,O)),
            ((X,X,O,O),
             (O,X,X,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((O,X,X,O),
             (X,X,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((O,X,O,O),
             (X,X,O,O),
             (X,O,O,O),
             (O,O,O,O)),
            ((X,O,O,O),
             (X,X,O,O),
             (O,X,O,O),
             (O,O,O,O)),
            ((X,X,X,O),
             (O,X,O,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((O,X,O,O),
             (X,X,X,O),
             (O,O,O,O),
             (O,O,O,O)),
            ((X,O,O,O),
             (X,X,O,O),
             (X,O,O,O),
             (O,O,O,O)),
            ((O,X,O,O),
             (X,X,O,O),
             (O,X,O,O),
             (O,O,O,O)),
            ((X,X,O,O),
             (X,X,O,O),
             (O,O,O,O),
             (O,O,O,O)));

   scrx0 = 10; scry0 = 6;
   sc2x0 = 46; sc2y0 = 6;
   sc3x0 = 10; sc3y0 = 13;
   sc4x0 = 46; sc4y0 = 13;             { координаты вывода игровых полей }
   cBar = #$db;                 { код символа "закрашеный прямоугольник" }
   { цвета }
   colO = DarkGray;                                { незакрашеной ячейки }
   colX = White;                                     { закрашеной ячейки }
   colKilled = Red;                               { убитая палуба игрока }
   colMilky = Black;                                 { промах компьютера }
   colKilled1 = LightCyan;                      { палуба, убитая игроком }
   colMilky1 = Black;                                    { промах игрока }
   colCursor = LightRed;                                        { курсор }
   colMessage = LightRed;                              { текст сообщения }
   colInactive = Black;        { ячейка, в которой не может быть корабля }
   { коды клавиатуры }
   keyUp    = #$48;
   keyLeft  = #$4b;
   keyDown  = #$50;
   keyRight = #$4d;
   keySpace = #$20;
   keyEnter = #$0d;
   keyEsc   = #$1b;
   { сообщения }
   loser_mes = 'You are loser! ;-)';
   winner_mes = 'You are winner!';

var pli: integer;                { вид корабля при расстановке кораблей }
    lxf,lyf: integer;           { координаты курсора при последнем ходе }
    origmode: integer;      { текстовый режим, который использовался до
                                                      запуска программы }
    maxx,maxy: integer;   { максимальные координаты текущего текстового
                                                                 режима }

procedure show_ansi(const pic: array of char; width, depth, x0, y0: integer);
{ Вывести на экран цветную картинку }
var i,j,num: integer;
begin
   for j:=1 to depth do
   for i:=1 to width do begin
      num:=(i-1+(j-1)*width)*2;
      if pic[num] <> #$20 then begin
         gotoxy(x0+i-1,y0+j-1);
         textcolor(ord(pic[num+1]));
         write(pic[num]);
       end;
   end;
end;

procedure message(str: string);
{ Вывести на экран сообщение, ожидать нажатия любой клавиши }
const x0 = 20; y0 = 9;
begin
   show_ansi(message_pic, message_pic_WIDTH, message_pic_DEPTH, x0, y0);
   window(x0+1,y0+1,x0+40,y0+6);
   clrscr;
   window(x0+6,y0+2,x0+40,y0+6);
   gotoxy(x0+15,y0+3);
   textcolor(colMessage);
   write(str);
   window(1,1,maxx,maxy);
   readkey;
end;

function check(i: integer): boolean;
{ Проверить, попадает ли координата i в игровое поле }
begin
   if (i >= 1) and (i <= numOfCells) then check:=true
   else check:=false;
end;

function area_includes(cell: tCell; const f: tField;
                       x0,y0: integer): boolean;
{ Проверить, включает ли область на игровом поле вокруг данной ячейки
  ячейку, содержащюю cell }
var i,j: integer;
begin
   for i:=x0-1 to x0+1 do
   for j:=y0-1 to y0+1 do
   if check(i) and check(j) and ((i<>x0) or (j<>y0)) then
      if f[i,j] = cell then begin
         area_includes:=true;
         exit;
      end;
   area_includes:=false;
end;

function place_cell(var f: tField; xf,yf: integer): boolean;
{ Поместить ячейку на игровое поле, выполнив проверку
  правильности }
begin
   if check(xf) and check(yf) and (f[xf,yf]<>X) then begin
      f[xf,yf]:=X;
      place_cell:=true;
   end
   else place_cell:=false;
end;

function place_ship(const ship: tShipOnField; var f: tField): boolean;
{ Поместить корабль на игровое поле,
  выполнив проверку правильности }
var i,j: integer;
    tf: tField;
begin
   tf:=f;
   for i:=1 to maxShip do
   for j:=1 to maxShip do
      if (shipMaps[ship.sindex][i,j] = X)
      and (area_includes(X,f,ship.x+i-1,ship.y+j-1)
            or not place_cell(tf,ship.x+i-1,ship.y+j-1)) then begin
         place_ship := false;
         exit;
      end;
   f:=tf;
   place_ship:=true;
end;

procedure init_field(var f: tField; cell: tCell);
{ очистить игровое поле }
var i,j: integer;
begin
   for i:=1 to numOfCells do
   for j:=1 to numOfCells do
      f[i,j]:=cell;
end;

function ship_killed(const f: tShipsField;
                     const pf: tField; i: integer): boolean;
{ проверить, убит ли корабль }
var j,k: integer;
begin
   for j:=1 to maxShip do
   for k:=1 to maxShip do
      if (shipMaps[f[i].sindex][j,k] = X)
      and (pf[j+f[i].x-1,k+f[i].y-1] = O) then begin
         ship_killed:=false;
         exit;
      end;
   ship_killed:=true;
end;

procedure ships_to_field(const f: tShipsField; var pf: tField; num: integer);
{ Преобразовать поле кораблей в поле ячеек }
var i: integer;
begin
   init_field(pf,O);
   for i:=1 to num do
{$IFDEF DEBUG}
      if not place_ship(f[i], pf) then message('Error placing ship to field');
{$ELSE}
      place_ship(f[i], pf);
{$ENDIF}
end;

procedure place_area(var f: tField; xf,yf: integer);
{ поместить на поле ячейки, находящиеся вокруг
  данной ячейки }
var i,j: integer;
begin
   for i:=xf-1 to xf+1 do
   for j:=yf-1 to yf+1 do
   if check(i) and check(j) then f[i,j] := X;
end;

procedure smart_turn(var f: tField; const ships: tShipsField);
{ Сделать "умный" ход }
var xf,yf: integer;
    i,j,k: integer;
    m,n: integer;
    tf,                   { поле всех ячеек, в которых может находиться }
                          { палуба }
    stf,                  { поле кораблей противника }
    tf1: tField;          { поле всех ячеек, находящихся рядом с подбитыми
                          { палубами }
    tf1_empty: boolean;
begin
   tf:=f;
   { Создать поле tf }
   for i:=1 to numOfShips do
      if ship_killed(ships,tf,i) then
         for j:=1 to maxShip do
         for k:=1 to maxShip do
            if shipMaps[ships[i].sindex][j,k] = X then
               place_area(tf,j-1+ships[i].x,k-1+ships[i].y);

   { Создать поле tf1 }
   ships_to_field(ships,stf,numOfCells);
   init_field(tf1,O);
   tf1_empty:=true;
   for i:=1 to numOfCells do
   for j:=1 to numOfCells do
      if (stf[i,j] = X) and (tf[i,j] = X) and area_includes(O,tf,i,j) then begin
         for m:=i-1 to i+1 do
         for n:=j-1 to j+1 do
            if (m = i) or (n = j) then
            if check(m) and check(n) and (tf[m,n] = O) then begin
               tf1[m,n]:=X;
               tf1_empty:=false;
            end;
      end;

   if not tf1_empty then begin
      for i:=1 to numOfCells do
      for j:=1 to numOfCells do
         if tf1[i,j] = X then tf1[i,j] := O
         else tf1[i,j] := X;

      tf:=tf1;
   end;

   { Сделать выстрел в случайную ячейку tf }
   repeat
      xf:=1+random(numOfCells);
      yf:=1+random(numOfCells);
   until place_cell(tf,xf,yf);
   place_cell(f,xf,yf);
end;

function end_of_game(const ships: tShipsField;
                     const pf: tField): boolean;
{ Проверить, закончилась ли игра }
var i,j: integer;
    tf: tField;
begin
   ships_to_field(ships,tf,numOfShips);
   for i:=1 to numOfCells do
   for j:=1 to numOfCells do
   if (tf[i,j] = X) and (pf[i,j] = O) then begin
      end_of_game:=false;
      exit;
   end;
   end_of_game:=true;
end;

procedure draw_bar(x0,y0,xf,yf: integer);
{ нарисовать квадратик }
begin
   gotoxy(x0+1+xf*2,y0+1+yf);
   write(cBar+cBar);
end;

procedure draw_field(const f: tField; x0,y0,col: integer);
var i,j: integer;
begin
   textcolor(col);
   for i:=1 to numOfCells do
   for j:=1 to numOfCells do
      if f[i,j] = X then draw_bar(x0,y0,i,j);
end;

procedure draw_custom_field(const f: tShipsField;
                            x0,y0,num: integer);
{ нарисовать поле кораблей. используется при расстановке кораблей }
var tf,emf: tField;
begin
   show_ansi(field_frame, field_frame_WIDTH, field_frame_DEPTH, x0, y0);

   init_field(emf,X);
   draw_field(emf,x0,y0,colO);

   ships_to_field(f,tf,num);
   draw_field(tf,x0,y0,colX);
end;

procedure draw_play_field(const pf: tField;
                          const ships: tShipsField; x0,y0: integer);
{ нарисовать игровое поле }
var i,j,k: integer;
    tf,tf1,tf2: tField;
begin
   show_ansi(field_frame, field_frame_WIDTH, field_frame_DEPTH, x0, y0);

   init_field(tf,X);
   draw_field(tf,x0,y0,colO);

   init_field(tf,O);
   for i:=1 to numOfShips do
      if ship_killed(ships,pf,i) then
         for j:=1 to maxShip do
         for k:=1 to maxShip do
            if shipMaps[ships[i].sindex][j,k] = X then
               place_area(tf,j-1+ships[i].x,k-1+ships[i].y);
   draw_field(tf,x0,y0,colInactive);

   ships_to_field(ships,tf,numOfShips);
   init_field(tf1,O);
   init_field(tf2,O);
   for i:=1 to numOfCells do
   for j:=1 to numOfCells do
      if pf[i,j] = X then begin
         if tf[i,j] = X then tf1[i,j]:=X
         else tf2[i,j]:=X;
      end;
   draw_field(tf1,x0,y0,colKilled1);
   draw_field(tf2,x0,y0,colMilky1);
end;

procedure draw_ships_field(const f: tShipsField;
                           const pf: tField; x0,y0: integer);
{ нарисовать поле кораблей }
var i,j: integer;
    tf: tField;
begin
   show_ansi(field_frame, field_frame_WIDTH, field_frame_DEPTH, x0, y0);
   ships_to_field(f,tf,numOfShips);
   for i:=1 to numOfCells do
   for j:=1 to numOfCells do begin
      if tf[i,j] = X then begin
         if pf[i,j] = X then textcolor(colKilled)
         else textcolor(colX);
      end
      else begin
         if pf[i,j] = X then textcolor(colMilky)
         else textcolor(colO);
      end;
      draw_bar(x0,y0,i,j);
   end;
end;

procedure show_random_background;
var n: integer;
begin
   clrscr;
   n:=random(8);
   case n of
      0: show_ansi(pic_a,pic_a_WIDTH,pic_a_DEPTH,1,1);
      1: show_ansi(pic_b,pic_b_WIDTH,pic_b_DEPTH,1,1);
      2: show_ansi(pic_c,pic_c_WIDTH,pic_c_DEPTH,1,1);
      3: show_ansi(pic_d,pic_d_WIDTH,pic_d_DEPTH,1,1);
      4: show_ansi(pic_e,pic_e_WIDTH,pic_e_DEPTH,1,1);
      5: show_ansi(pic_f,pic_f_WIDTH,pic_f_DEPTH,1,1);
      6: show_ansi(pic_g,pic_g_WIDTH,pic_g_DEPTH,1,1);
      7: show_ansi(pic_h,pic_h_WIDTH,pic_h_DEPTH,1,1);
   end;
   readkey;
end;

procedure systemfont; external; {$L font.obj}
procedure init_screen;
{ очистить экран, установить нужные атрибуты экрана }
begin
   origmode:=LastMode;
   { текстовый режим }
   maxx:=80; maxy:=25;
   textmode(co80);
   { шрифт }
   asm
      mov       ax,seg systemfont
      mov       es,ax
      mov       bp,offset systemfont
      mov       ax,1100h
      mov       bx,1000h
      mov       cx,256
      mov       dx,0
      int       10h
   { курсор }
      mov       ah,01h
      mov       ch,1
      mov       cl,0
      int       10h
   end;
   highvideo;
   clrscr;
   show_random_background;
end;

procedure close_screen;
{ очистить экран по завершении программы }
begin
   clrscr;
   textmode(origmode);
   writeln('Used art from /mimic/ and /karma/ packs');
   writeln(' -- thuglife.org');
end;

procedure input_turn(var game: tGame);
{ запросить у игрока ввод хода }
begin
   with game do begin
      draw_ships_field(hShips,cField,scrx0,scry0);
      repeat
         draw_play_field(hField,cShips,sc2x0,sc2y0);
         textcolor(colCursor);
         draw_bar(sc2x0,sc2y0,lxf,lyf);
         case readkey of
            keyUp: dec(lyf);
            keyDown: inc(lyf);
            keyLeft: dec(lxf);
            keyRight: inc(lxf);
            keyEsc: begin
                       close_screen;
                       halt;
                    end;
            keySpace: if place_cell(hField,lxf,lyf) then exit;
         end;
         if (lxf < 1) then lxf:=numOfCells
         else if (lxf > numOfCells) then lxf:=1;
         if (lyf < 1) then lyf:=numOfCells
         else if (lyf > numOfCells) then lyf:=1;
      until false;
   end;
end;

function check_ships_field(const f: tShipsField; num: integer): boolean;
{ проверить правильность расположения
  num первых кораблей на поле игрока }
var tf: tField;
    i: integer;
begin
   init_field(tf,O);
   for i:=1 to num do
      if not place_ship(f[i], tf) then begin
         check_ships_field:=false;
         exit;
      end;
   check_ships_field:=true;
end;

procedure draw_ship(const ship: tShip; x0,y0,xf,yf: integer);
{ нарисовать корабль }
var i,j: integer;
begin
   textcolor(colX);
   for i:=1 to maxShip do
   for j:=1 to maxShip do
      if (ship[i,j] = X) and check(xf+i-1) and check(yf+j-1) then
         draw_bar(x0,y0,xf+i-1,yf+j-1);
end;

procedure human_place(var f: tShipsField; k: integer; sType: tShipType); far;
{ запросить у игрока поместить корабль на поле }
begin
   repeat
      if not ((pli>=Ships[sType].index)
      and (pli<Ships[sType].index + Ships[sType].varnum)) then
         pli:=Ships[sType].index;

      draw_custom_field(f,scrx0,scry0,k);
      draw_ship(shipMaps[pli],scrx0,scry0,lxf,lyf);
      case readkey of
         keyUp: dec(lyf);
         keyDown: inc(lyf);
         keyLeft: dec(lxf);
         keyRight: inc(lxf);
         keySpace: pli:=Ships[sType].index
                   + (pli+1) mod Ships[sType].varnum;
         keyEnter: begin
                      with f[k] do begin
                         x:=lxf; y:=lyf;
                         sindex:=pli;
                      end;
                      if check_ships_field(f,k) then exit;
                   end;
         keyEsc: begin
                    close_screen;
                    halt;
                 end;
      end;
      if (lxf < 1) then lxf:=numOfCells
      else if (lxf > numOfCells) then lxf:=1;
      if (lyf < 1) then lyf:=numOfCells
      else if (lyf > numOfCells) then lyf:=1;
   until false;
end;

procedure random_place(var f: tShipsField; k: integer; i: tShipType); far;
{ Ставит корабль в случайное место на поле }
begin
   with f[k] do
   repeat
      sindex:=Ships[i].index+random(Ships[i].varnum);
      x:=1+random(numOfCells);
      y:=1+random(numOfCells);
   until check_ships_field(f,k);
end;

procedure place_ships(var f: tShipsField; place: tPlaceProc);
{ Расставить корабли в соответствии с указанной процедурой }
var i: tShipType;
    j,k: integer;
begin
   k:=1;
   for i:=Ship4 downto Ship1 do
      for j:=1 to Ships[i].num do begin
         place(f, k, i);
         inc(k);
      end;
end;

var
   game: tGame;
begin
   randomize;
   init_screen;

   with game do begin
      { начало игры: установить все игровые поля и переменные }
      init_field(hField,O);
      init_field(cField,O);
      place_ships(cShips, random_place);
{$IFDEF DEBUG}
      place_ships(hShips, random_place);
{$ELSE}
      lxf:=1; lyf:=1;
      pli:=1;
      place_ships(hShips, human_place);
{$ENDIF}
      lxf:=1; lyf:=1;
      currPl:=plHuman;

      repeat
         if currPl = plHuman then begin
            input_turn(game);
            currPl:=plComp;
         end
         else begin
            smart_turn(cField,hShips);
{$IFDEF DEBUG}
            draw_play_field(cField,hShips,sc3x0,sc3y0);
            draw_ships_field(cShips,hField,sc4x0,sc4y0);
{$ENDIF}
            currPl:=plHuman;
         end;
      until end_of_game(hShips, cField)
            or end_of_game(cShips, hField);

      if currPl <> plHuman then message(winner_mes)
      else message(loser_mes);
   end;

   close_screen;
end.
