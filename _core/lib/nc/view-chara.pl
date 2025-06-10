use strict;
use utf8;
use open ":utf8";

our %pc = getSheetData();

print "Content-Type: text/html\n\n";
print "<html><head><meta charset=\"UTF-8\"><title>$pc{characterName} - $set::title</title></head><body>";
print "<h1>$pc{characterName}</h1>";
print "<p>プレイヤー: $pc{playerName}</p>";
print "</body></html>";

1;
