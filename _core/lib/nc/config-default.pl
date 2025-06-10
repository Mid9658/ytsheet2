use strict;
use utf8;
package set;

our $game  = 'nc';
our $title = 'ゆとシートⅡ for Nechronica';

# HTML templates
our $skin_tmpl  = $::core_dir . '/skin/nc/index.html';
our $skin_sheet = $::core_dir . '/skin/nc/sheet-chara.html';

# データ保存先
our $data_dir  = './data/';
our $passfile  = $data_dir . 'charpass.cgi';
our $listfile  = $data_dir . 'charlist.cgi';
our $char_dir  = $data_dir . 'chara/';

# 各種ファイルへのパス
our $userfile    = $::core_dir . '/data/users.cgi';
our $login_users = $::core_dir . '/data/login_users.cgi';
our $tokenfile   = $::core_dir . '/data/token.cgi';

our $lib_form     = $::core_dir . '/lib/form.pl';
our $lib_info     = $::core_dir . '/lib/info.pl';
our $lib_register = $::core_dir . '/lib/register.pl';
our $lib_reminder = $::core_dir . '/lib/reminder.pl';
our $lib_delete   = $::core_dir . '/lib/delete.pl';
our $lib_others   = $::core_dir . '/lib/others.pl';

# 編集・表示関連
our $lib_edit      = $::core_dir . '/lib/edit.pl';
our $lib_edit_char = $::core_dir . '/lib/nc/edit-chara.pl';
our $lib_save      = $::core_dir . '/lib/save.pl';
our $lib_calc_char = $::core_dir . '/lib/nc/calc-chara.pl';
our $lib_view      = $::core_dir . '/lib/view.pl';
our $lib_view_char = $::core_dir . '/lib/nc/view-chara.pl';
our $lib_palette   = $::core_dir . '/lib/palette.pl';

# 一覧表示用ライブラリ
our $lib_list_char = $::core_dir . '/lib/nc/list-chara.pl';


1;
