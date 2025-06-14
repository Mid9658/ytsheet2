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
  if($i == 1){
    $pc{"fetterTarget1"} ||= 'たからもの';
    $pc{"fetterNote1"}   ||= '依存';
    $pc{"fetterEffect1"} ||= '幼児退行';
    $pc{"fetterPoint1"}  ||= 3;
  }
  else {
    $pc{"fetterPoint$i"} ||= '';
  }
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

my $maneuver_rows_html = '';
foreach my $i (1 .. $pc{maneuverNum}){
  $maneuver_rows_html .= <<"HTML";
      <tr id="maneuver-row${i}">
        <td class="handle"></td>
        <td>@{[ input "maneuverBroken${i}", 'checkbox' ]}</td>
        <td>@{[ input "maneuverUsed${i}",   'checkbox' ]}</td>
        <td><select name="maneuverPart${i}">@{[ option "maneuverPart${i}",'スキル','頭','腕','胴','脚' ]}</select></td>
        <td>@{[ input "maneuverName${i}" ]}</td>
        <td><select name="maneuverTiming${i}">@{[ option "maneuverTiming${i}",'オート','アクション','ラピッド','ジャッジ','ダメージ','効果参照' ]}</select></td>
        <td>@{[ input "maneuverCost${i}" ]}</td>
        <td>@{[ input "maneuverRange${i}" ]}</td>
        <td>@{[ input "maneuverNote${i}" ]}</td>
      </tr>
HTML
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
  ManeuverRowsHTML => $maneuver_rows_html,
  Groups       => \@groups,
  forbiddenBattle => ($pc{forbidden} eq 'battle' ? 1 : 0),
  forbiddenAll    => ($pc{forbidden} eq 'all'    ? 1 : 0),
  Menu         => [ { TEXT => '一覧へ', TYPE => 'href', VALUE => './', SIZE => 'small' } ],
);

print "Content-Type: text/html\n\n";
print $tmpl->output;

1;
