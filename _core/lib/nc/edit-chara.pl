use strict;
use utf8;
use open ":utf8";
use HTML::Template;

my $LOGIN_ID = $::LOGIN_ID;

### データ読み込み ###############################################################
my ($data, $mode, $file, $message) = getSheetData($::in{mode});
our %pc = %{ $data };
##

my $mode_make = ($mode =~ /^(?:blanksheet|copy|convert)$/) ? 1 : 0;
my $token = $mode_make ? tokenMake() : '';

if($mode_make){
  $pc{protect} ||= $LOGIN_ID ? 'account' : 'password';
}

## 画像初期値
$pc{imageFit}      = $pc{imageFit} eq 'percent' ? 'percentX' : $pc{imageFit};
$pc{imagePercent}   //= '200';
$pc{imagePositionX} //= '50';
$pc{imagePositionY} //= '50';
$pc{wordsX} ||= '右';
$pc{wordsY} ||= '上';
$pc{enhanceArmsGrow}   ||= 0;
$pc{enhanceMutateGrow} ||= 0;
$pc{enhanceModifyGrow} ||= 0;
$pc{enhanceAny}       ||= '';
$pc{maneuverNum}      ||= do {
  my $max = 0;
  foreach my $key (keys %pc){
    if($key =~ /^maneuverName(\d+)$/){
      my $num = $1;
      $max = $num if $num > $max;
    }
  }
  $max || 6;
};
$pc{memoryNum}        ||= 2;
foreach my $i (1 .. 6){
  $pc{"fetterPoint$i"} ||= ($i == 1 ? 3 : '');
}
$pc{memoryNum}        ||= 2;
$pc{forbidden}        ||= '';
$pc{group}            ||= $set::group_default if defined $set::group_default;
$pc{tags}             ||= '';
$pc{hide}             ||= 0;

my @classes = (
  'ステーシー','タナトス','ゴシック','レクイエム','バロック','ロマネスク','サイケデリック'
);
my @positions = (
  'アリス','ホリック','オートマトン','ジャンク','コート','ソロリティ'
);
my %main_selected; my %sub_selected;
foreach my $i (0..$#classes){
  $main_selected{$i+1} = 'selected' if $pc{mainClass} eq $classes[$i];
  $sub_selected{$i+1}  = 'selected' if $pc{subClass}  eq $classes[$i];
}
my %position_selected;
foreach my $i (0..$#positions){
  $position_selected{$i+1} = 'selected' if $pc{position} eq $positions[$i];
}
my %any_checked = (
  arms   => ($pc{enhanceAny} eq 'arms'   ? 'checked' : ''),
  mutate => ($pc{enhanceAny} eq 'mutate' ? 'checked' : ''),
  modify => ($pc{enhanceAny} eq 'modify' ? 'checked' : ''),
);

my %class_bonus = (
  'ステーシー'     => { arms => 1, mutate => 1, modify => 0 },
  'タナトス'      => { arms => 1, mutate => 0, modify => 1 },
  'ゴシック'      => { arms => 0, mutate => 1, modify => 1 },
  'レクイエム'    => { arms => 2, mutate => 0, modify => 0 },
  'バロック'      => { arms => 0, mutate => 2, modify => 0 },
  'ロマネスク'    => { arms => 0, mutate => 0, modify => 2 },
  'サイケデリック'=> { arms => 0, mutate => 0, modify => 1 },
);

my ($arms, $mutate, $modify) = (0,0,0);
my %main_bonus; my %sub_bonus;
if(my $b = $class_bonus{$pc{mainClass}}){
  %main_bonus = %{$b};
  $arms   += $b->{arms};
  $mutate += $b->{mutate};
  $modify += $b->{modify};
}
if(my $b = $class_bonus{$pc{subClass}}){
  %sub_bonus = %{$b};
  $arms   += $b->{arms};
  $mutate += $b->{mutate};
  $modify += $b->{modify};
}
$pc{mainClassArms}   = $main_bonus{arms}   || 0;
$pc{mainClassMutate} = $main_bonus{mutate} || 0;
$pc{mainClassModify} = $main_bonus{modify} || 0;
$pc{subClassArms}    = $sub_bonus{arms}    || 0;
$pc{subClassMutate}  = $sub_bonus{mutate}  || 0;
$pc{subClassModify}  = $sub_bonus{modify}  || 0;
if   ($pc{enhanceAny} eq 'arms'  ){ $arms++;   }
elsif($pc{enhanceAny} eq 'mutate'){ $mutate++; }
elsif($pc{enhanceAny} eq 'modify'){ $modify++; }
$pc{enhanceArms}   = $arms;
$pc{enhanceMutate} = $mutate;
$pc{enhanceModify} = $modify;
$pc{enhanceArmsTotal}   = $arms   + $pc{enhanceArmsGrow};
$pc{enhanceMutateTotal} = $mutate + $pc{enhanceMutateGrow};
$pc{enhanceModifyTotal} = $modify + $pc{enhanceModifyGrow};

my @groups;
foreach (@set::groups){
  my ($id, undef, $name, undef, $exclusive) = @$_;
  next if($exclusive && (!$LOGIN_ID || $LOGIN_ID !~ /^($exclusive)$/));
  push @groups, { ID=>$id, NAME=>$name, SELECTED=>($pc{group} eq $id ? 1:0) };
}

my @maneuver_rows;
foreach my $i (1 .. $pc{maneuverNum}){
  push @maneuver_rows, {
    ID    => $i,
    BROKEN=> ($pc{"maneuverBroken$i"} ? 'checked' : ''),
    USED  => ($pc{"maneuverUsed$i"} ? 'checked' : ''),
    PART_SKILL => ($pc{"maneuverPart$i"} eq 'スキル' ? 'selected' : ''),
    PART_HEAD  => ($pc{"maneuverPart$i"} eq '頭' ? 'selected' : ''),
    PART_ARM   => ($pc{"maneuverPart$i"} eq '腕' ? 'selected' : ''),
    PART_BODY  => ($pc{"maneuverPart$i"} eq '胴' ? 'selected' : ''),
    PART_LEG   => ($pc{"maneuverPart$i"} eq '脚' ? 'selected' : ''),
    NAME   => pcEscape(pcUnescape($pc{"maneuverName$i"})),
    TIMING_AUTO   => ($pc{"maneuverTiming$i"} eq 'オート'     ? 'selected' : ''),
    TIMING_ACTION => ($pc{"maneuverTiming$i"} eq 'アクション' ? 'selected' : ''),
    TIMING_RAPID  => ($pc{"maneuverTiming$i"} eq 'ラピッド'   ? 'selected' : ''),
    TIMING_JUDGE  => ($pc{"maneuverTiming$i"} eq 'ジャッジ'   ? 'selected' : ''),
    TIMING_DAMAGE => ($pc{"maneuverTiming$i"} eq 'ダメージ'   ? 'selected' : ''),
    TIMING_REF    => ($pc{"maneuverTiming$i"} eq '効果参照'   ? 'selected' : ''),
    COST   => pcEscape(pcUnescape($pc{"maneuverCost$i"})),
    RANGE  => pcEscape(pcUnescape($pc{"maneuverRange$i"})),
    NOTE   => pcEscape(pcUnescape($pc{"maneuverNote$i"})),
  };
}

my @memory_rows;
foreach my $i (1 .. $pc{memoryNum}){
  push @memory_rows, {
    ID   => $i,
    NAME => pcEscape(pcUnescape($pc{"memoryName$i"})),
    NOTE => pcEscape(pcUnescape($pc{"memoryNote$i"})),
  };
}

my @fetter_rows;
foreach my $i (1 .. 6){
  push @fetter_rows, {
    ID     => $i,
    TARGET => pcEscape(pcUnescape($pc{"fetterTarget$i"})),
    NOTE   => pcEscape(pcUnescape($pc{"fetterNote$i"})),
    EFFECT => pcEscape(pcUnescape($pc{"fetterEffect$i"})),
    POINT  => pcEscape(pcUnescape($pc{"fetterPoint$i"})),
  };
}

my $titleName = ($mode eq 'edit') ? '編集' : '新規作成';
my $passHidden = ($mode eq 'edit' && $pc{protect} eq 'password' && $::in{pass}) ? 1 : 0;

my $imageForm = imageForm($pc{imageURL});

my $tmpl = HTML::Template->new(
  filename          => $::core_dir.'/skin/nc/edit-chara.html',
  utf8              => 1,
  path              => ['./', $::core_dir.'/skin/nc', $::core_dir.'/skin/_common', $::core_dir],
  search_path_on_include => 1,
  die_on_bad_params => 0,
  die_on_missing_include => 0,
  case_sensitive    => 1,
  global_vars       => 1,
);

$tmpl->param(
  title        => $set::title,
  titleName    => $titleName,
  ver          => $main::ver,
  coreDir      => $::core_dir,
  mode         => ($mode eq 'edit' ? 'save' : 'make'),
  token        => $token,
  id           => $pc{id},
  protect      => $pc{protect},
  protectOld   => $pc{protect},
  protectAccount  => ($pc{protect} eq 'account' ? 1 : 0),
  protectPassword => ($pc{protect} eq 'password' ? 1 : 0),
  protectNone     => ($pc{protect} eq 'none' ? 1 : 0),
  LOGIN_ID     => $LOGIN_ID,
  pass         => $::in{pass},
  passHidden   => $passHidden,
  characterName=> $pc{characterName},
  playerName   => $pc{playerName},
  age          => $pc{age},
  gender       => $pc{gender},
  height       => $pc{height},
  weight       => $pc{weight},
  mainClass    => $pc{mainClass},
  subClass     => $pc{subClass},
  enhanceAny   => $pc{enhanceAny},
  enhanceArms  => $pc{enhanceArms},
  enhanceMutate=> $pc{enhanceMutate},
  enhanceModify=> $pc{enhanceModify},
  mainClassArms     => $pc{mainClassArms},
  mainClassMutate   => $pc{mainClassMutate},
  mainClassModify   => $pc{mainClassModify},
  subClassArms      => $pc{subClassArms},
  subClassMutate    => $pc{subClassMutate},
  subClassModify    => $pc{subClassModify},
  enhanceArmsTotal   => $pc{enhanceArmsTotal},
  enhanceMutateTotal => $pc{enhanceMutateTotal},
  enhanceModifyTotal => $pc{enhanceModifyTotal},
  enhanceArmsGrow   => $pc{enhanceArmsGrow},
  enhanceMutateGrow => $pc{enhanceMutateGrow},
  enhanceModifyGrow => $pc{enhanceModifyGrow},
  actionPoint  => $pc{actionPoint},
  imageURL     => $pc{imageURL},
  imageForm    => $imageForm,
  memoryNum    => $pc{memoryNum},
  MemoryRows   => \@memory_rows,
  FetterRows   => \@fetter_rows,
  freeNote     => do { my $t = pcUnescape($pc{freeNote}); $t =~ s/&lt;br&gt;/\n/g; pcEscape($t) },
  forbidden    => $pc{forbidden},
  hide         => $pc{hide},
  group        => $pc{group},
  tags         => $pc{tags},
  position     => $pc{position},
  map { ("positionSelected".($_+1) => $position_selected{$_+1}) } 0..$#positions,
  map { ("mainClassSelected".($_+1) => $main_selected{$_+1}) } 0..$#classes,
  map { ("subClassSelected" .($_+1) => $sub_selected{$_+1})  } 0..$#classes,
  enhanceAnyArms   => $any_checked{arms},
  enhanceAnyMutate => $any_checked{mutate},
  enhanceAnyModify => $any_checked{modify},
  maneuverNum   => $pc{maneuverNum},
  ManeuverRows  => \@maneuver_rows,
  Groups       => \@groups,
  forbiddenBattle => ($pc{forbidden} eq 'battle' ? 1 : 0),
  forbiddenAll    => ($pc{forbidden} eq 'all'    ? 1 : 0),
  Menu         => [ { TEXT => '一覧へ', TYPE => 'href', VALUE => './', SIZE => 'small' } ],
);

print "Content-Type: text/html\n\n";
print $tmpl->output;

1;
