use strict;
use utf8;

sub data_calc {
  my %pc = %{$_[0]};
  $pc{birthTime} ||= time;
  $pc{characterName} ||= '';
  $pc{playerName} ||= '';
  $pc{group} ||= $set::group_default if defined $set::group_default;
  $pc{tags} ||= '';
  $pc{hide} ||= 0;

  ### 記憶のカケラ
  $pc{memoryNum} ||= 2;
  $pc{memoryNum} = 6 if $pc{memoryNum} > 6;
  foreach my $i (1 .. $pc{memoryNum}){
    $pc{"memoryName$i"} ||= '';
    $pc{"memoryNote$i"} ||= '';
  }

  ### 未練／狂気
  foreach my $i (1 .. 6){
    if($i == 1){
      $pc{"fetterTarget1"} ||= 'たからもの';
      $pc{"fetterNote1"}   ||= '依存';
      $pc{"fetterEffect1"} ||= '幼児退行';
      $pc{"fetterPoint1"}  ||= 3;
    }
    else {
      $pc{"fetterTarget$i"} ||= '';
      $pc{"fetterNote$i"}   ||= '';
      $pc{"fetterEffect$i"} ||= '';
      $pc{"fetterPoint$i"}  ||= '';
    }
  }

  $pc{enhanceAny} ||= '';
  $pc{enhanceArmsGrow}   ||= 0;
  $pc{enhanceMutateGrow} ||= 0;
  $pc{enhanceModifyGrow} ||= 0;

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
  my %main_bonus;
  my %sub_bonus;
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

  $pc{freeNote} =~ s/\r\n?|\n/<br>/g;

  if(!$::mode_save){ return %pc; }

  $pc{$_} = pcEscape($pc{$_}) foreach (keys %pc);
  $pc{tags} = normalizeHashtags($pc{tags});

  $::newline = "$pc{id}<>$::file<>$pc{birthTime}<>$::now<>$pc{characterName}<>$pc{playerName}<>$pc{group}<>$pc{lastSession}<>$pc{image}<> $pc{tags} <>$pc{hide}<>";
  return %pc;
}

1;
