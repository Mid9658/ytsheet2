use strict;
use utf8;
use open ":utf8";
use HTML::Template;

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

$tmpl->param(
  title        => $set::title,
  ver          => $main::ver,
  coreDir      => $::core_dir,
  titleName    => 'キャラクターシート',
  %pc,
  Menu         => [ { TEXT => '編集', TYPE => 'href', VALUE => "./?mode=edit&id=$::in{id}", SIZE => 'small' } ],
);

print "Content-Type: text/html\n\n";
print $tmpl->output;

1;
