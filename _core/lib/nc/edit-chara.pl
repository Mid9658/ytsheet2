use strict;
use utf8;
use open ":utf8";
use HTML::Template;

our %pc;
our $mode;

my $titleName = ($mode eq 'edit') ? '編集' : '新規作成';

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
  id           => $pc{id},
  characterName=> $pc{characterName},
  playerName   => $pc{playerName},
  aka          => $pc{aka},
  age          => $pc{age},
  gender       => $pc{gender},
  enhanceArms  => $pc{enhanceArms},
  enhanceMutate=> $pc{enhanceMutate},
  enhanceModify=> $pc{enhanceModify},
  actionPoint  => $pc{actionPoint},
  madnessPoint => $pc{madnessPoint},
  memory       => $pc{memory},
  freeNote     => $pc{freeNote},
  Menu         => [ { TEXT => '一覧へ', TYPE => 'href', VALUE => './', SIZE => 'small' } ],
);

print "Content-Type: text/html\n\n";
print $tmpl->output;

1;
