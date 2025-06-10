use strict;
use utf8;
use open ":utf8";

print "Content-Type: text/html\n\n";
print "<html><head><meta charset=\"UTF-8\"><title>キャラクター一覧 - $set::title</title></head><body>";
print "<h1>キャラクター一覧</h1>";

if(open my $FH, '<', $set::listfile){
  while(my $line = <$FH>){
    chomp $line;
    my ($id, undef, undef, undef, $name, $player) = split /<>/, $line;
    $name ||= '無題';
    print qq{<div><a href="./?id=$id">$name</a> ($player)</div>\n};
  }
  close $FH;
} else {
  print "<p>キャラクターは登録されていません。</p>";
}

print "</body></html>";

1;
