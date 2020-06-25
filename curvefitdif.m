clc;
clear all;



x1r = readtable("ValidationTest.xls", "Sheet",6, 'Range','N2:N383 ',"UseExcel", false);
y1r = readtable('ValidationTest.xls', 'Sheet',6, 'Range','A2:A383 ',"UseExcel", false);
 
x2r = readtable('ValidationTest.xls', 'Sheet',6, 'Range','O2:O866',"UseExcel", false);
y2r = readtable('ValidationTest.xls', 'Sheet',6, 'Range','B2:B866',"UseExcel", false);


x1 = mat2cell(x1r)
y1 = mat2cell(y1r)
x2 = mat2cell(x2r)
y2 = mat2cell(y2r)
 
P1 = polyfit(x1{:,:}, y1{:,:}, 6 ) 
P2 = polyfit(x2{:,:}, y2{:,:}, 6)
 
allX = unique([x1{:,:}; x2{:,:}]);
 
Pd = polyval(P1, allX) - polyval(P2, allX)
 
P11 = polyval(P1, allX)
P22 = polyval(P2, allX)
 
hold on
plot(allX, Pd, 'b')
plot(allX, P11, 'g')
plot(allX, P22, 'r')


