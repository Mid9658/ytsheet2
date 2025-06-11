use strict;
use utf8;
use open ":utf8";
use HTML::Template;

my $LOGIN_ID = $::LOGIN_ID;

our %pc = getSheetData();

my $tmpl = HTML::Template->new(
  filename          => $set::skin_sheet,
  utf8              => 1,
  path              => ['./', $::core_dir.'/skin/nc', $::core_dir.'/skin/_common', $::core_dir],
  search_path_on_include => 1,
  loop_context_vars => 1,
  die_on_bad_params => 0,
  die_on_missing_include => 0,
  case_sensitive    => 1,
  global_vars       => 1,
);

$pc{maneuverNum} ||= 3;
my @maneuvers;
foreach my $i (1 .. $pc{maneuverNum}){
  next if !existsRow "maneuver$i",'Name','Timing','Cost','Range','Note';
  push @maneuvers, {
    BROKEN => ($pc{"maneuverBroken$i"} ? '☑' : ''),
    USED   => ($pc{"maneuverUsed$i"}  ? '☑' : ''),
    PART   => $pc{"maneuverPart$i"},
    NAME   => $pc{"maneuverName$i"},
    TIMING => $pc{"maneuverTiming$i"},
    COST   => $pc{"maneuverCost$i"},
    RANGE  => $pc{"maneuverRange$i"},
    NOTE   => $pc{"maneuverNote$i"},
  };
}

if(!$pc{group}){
  $pc{group} = $set::group_default;
}
my $group_name = '';
foreach (@set::groups){
  if($pc{group} eq @$_[0]){ $group_name = @$_[2]; last; }
}
my @tags;
foreach(split(/ /, $pc{tags})){ push @tags, { URL => uri_escape_utf8($_), TEXT => $_ }; }

$tmpl->param(
  title        => $set::title,
  ver          => $main::ver,
  coreDir      => $::core_dir,
  titleName    => 'キャラクターシート',
  %pc,
  groupName   => $group_name,
  Tags        => \@tags,
  Maneuvers   => \@maneuvers,
);

my @menu;
if($pc{reqdPassword}){
  push @menu, { TEXT => '編集', TYPE => 'onclick', VALUE => 'editOn()', SIZE => 'small' };
}
else {
  push @menu, { TEXT => '編集', TYPE => 'href', VALUE => "./?mode=edit&id=$::in{id}", SIZE => 'small' };
}
$tmpl->param(Menu => \@menu);

print "Content-Type: text/html\n\n";
print $tmpl->output;

1;
