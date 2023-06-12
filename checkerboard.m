%left top right bottom
lefttop = [0 0];

siz = rctSize;
numCheckers = 4;
left = lefttop(1):siz/numCheckers:(siz+lefttop(1));
top  = lefttop(2):siz/numCheckers:(siz+lefttop(2));
oneRow = [left(1:numCheckers); top(1:numCheckers); left(2:(numCheckers+1))-1; top(2:(numCheckers+1))-1];

allRows = [];
for m = 0:(numCheckers-1)
    newRow = oneRow + [siz/numCheckers 0 siz/numCheckers 0]' * m;
    allRows = [allRows, newRow];
end

checkertmp  = reshape(repmat([1 0], 1, (numCheckers^2)/2), numCheckers, numCheckers)'; 
checkerrev  = repmat([1 -1], 1, (numCheckers)/2);
checkerplus = repmat([0 1], 1, (numCheckers)/2);
checkerCol1 = reshape((checkertmp.* checkerrev' + checkerplus')', 1, numCheckers^2);
checkerCol2 = abs(checkerCol1 + -1);


