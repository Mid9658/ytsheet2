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

  $::newline = "$pc{id}<>$::file<>$pc{birthTime}<>$::now<>$pc{characterName}<>$pc{playerName}<>$pc{group}<>$pc{lastSession}<>$pc{image}<> $pc{tags} <>$pc{hide}<>";
  return %pc;
}

1;
