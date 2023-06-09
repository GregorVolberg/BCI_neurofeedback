%left top right bottom
lefttop = [100 0];


siz = 100;
num = 4
left = lefttop(1):siz/num:(siz+lefttop(1));
top  = lefttop(2):siz/num:(siz+lefttop(2));
[left(1:num); top(1:num); left(2:(num+1))-1; top(2:(num+1))-1]

right = left +1

rects = 