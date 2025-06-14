use strict;
use subs qw/existsRow/;
use utf8;
use open ":utf8";
use HTML::Template;

my $LOGIN_ID = $::LOGIN_ID;

our %pc = getSheetData();

foreach my $i (1 .. 6){
  $pc{"fetterEffectNote$i"} = unescapeTags($pc{"fetterEffectNote$i"});
}

# 任意選択ボーナスの表示用
my %enhance_any_mark = (
  arms   => ($pc{enhanceAny} eq 'arms'   ? '+1' : ''),
  mutate => ($pc{enhanceAny} eq 'mutate' ? '+1' : ''),
  modify => ($pc{enhanceAny} eq 'modify' ? '+1' : ''),
);

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

$pc{memoryNum} ||= 0;
my @memory_rows;
foreach my $i (1 .. $pc{memoryNum}){
  push @memory_rows, {
    NAME => $pc{"memoryName$i"},
    NOTE => $pc{"memoryNote$i"},
  };
}

my @fetter_rows;
foreach my $i (1 .. 6){
  my $p = $pc{"fetterPoint$i"} || 0;
  my $mark = '○○○○';
  substr($mark,0,$p) = '●' x $p;
  push @fetter_rows, {
    TARGET    => $pc{"fetterTarget$i"},
    NOTE      => $pc{"fetterNote$i"},
    EFFECT    => $pc{"fetterEffect$i"},
    EFFECT_NOTE=> $pc{"fetterEffectNote$i"},
    POINT     => $p,
    POINT_MARK=> $mark,
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
  MemoryRows  => \@memory_rows,
  FetterRows  => \@fetter_rows,
  enhanceAnyArms   => $enhance_any_mark{arms},
  enhanceAnyMutate => $enhance_any_mark{mutate},
  enhanceAnyModify => $enhance_any_mark{modify},
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
