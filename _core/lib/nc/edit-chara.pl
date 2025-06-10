use strict;
use utf8;
use open ":utf8";

our %pc;
our $mode;

my $title = ($mode eq 'edit') ? '編集' : '新規作成';
print "Content-Type: text/html\n\n";
print "<html><head><meta charset=\"UTF-8\"><title>$title - $set::title</title></head><body>";
print "<h1>$title</h1>";
print "<form method=\"post\" action=\"./\" enctype=\"multipart/form-data\">";
print '<input type="hidden" name="mode" value="'.($mode eq 'edit'?'save':'make').'">';
print '<input type="hidden" name="id" value="'.$pc{id}.'">' if $mode eq 'edit';
print "<div>キャラクター名:<input name=\"characterName\" value=\"$pc{characterName}\"></div>";
print "<div>プレイヤー名:<input name=\"playerName\" value=\"$pc{playerName}\"></div>";
print '<div><input type="submit" value="保存"></div>';
print "</form></body></html>";

1;
