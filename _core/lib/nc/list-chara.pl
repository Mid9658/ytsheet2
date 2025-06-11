use strict;
use utf8;
use open ":utf8";
use HTML::Template;

my $LOGIN_ID = check;

my $INDEX = HTML::Template->new(
  filename          => $set::skin_tmpl,
  utf8              => 1,
  path              => ['./', "$::core_dir/skin/nc", "$::core_dir/skin/_common", $::core_dir],
  search_path_on_include => 1,
  die_on_bad_params => 0,
  die_on_missing_include => 0,
  case_sensitive    => 1,
  global_vars       => 1,
);

$INDEX->param(modeList => 1);
$INDEX->param(typeName => 'キャラ');
$INDEX->param(LOGIN_ID => $LOGIN_ID);
$INDEX->param(OAUTH_MODE => $set::oauth_service);
$INDEX->param(OAUTH_LOGIN_URL => $set::oauth_login_url);

my @characters;
if(open my $FH, '<', $set::listfile){
  while(my $line = <$FH>){
    chomp $line;
    my (
      $id, undef, undef, $update,
      $name, $player, $group, undef, undef, $tags
    ) = split /<>/, $line;
    push @characters, {
      'ID'       => $id,
      'NAME'     => ($name || '無題'),
      'PLAYER'   => $player,
      'GENDER'   => '',
      'AGE'      => '',
      'SIGN'     => '',
      'BLOOD'    => '',
      'WORKS'    => '',
      'EXP'      => '',
      'SYNDROME' => '',
      'DLOIS'    => '',
      'TAGS'     => $tags,
      'DATE'     => epocToDate($update),
    };
  }
  close $FH;
}

my @lists = ({
  'ID'        => 'all',
  'NAME'      => 'キャラクター',
  'TEXT'      => '',
  'NUM-PC'    => scalar @characters,
  'Characters'=> \@characters,
  'NAV'       => '',
});

$INDEX->param(Lists => \@lists);
$INDEX->param(title => $set::title);
$INDEX->param(ver => $::ver);
$INDEX->param(coreDir => $::core_dir);

print "Content-Type: text/html\n\n";
print $INDEX->output;

1;
