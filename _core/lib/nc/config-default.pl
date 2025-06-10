use strict;
use utf8;
package set;

our $game  = 'nc';
our $title = 'ゆとシートⅡ for Nechronica';

# HTML templates
our $skin_tmpl  = $::core_dir . '/skin/nc/index.html';
our $skin_sheet = $::core_dir . '/skin/nc/sheet-chara.html';

# 一覧表示用ライブラリ
our $lib_list_char = $::core_dir . '/lib/nc/list-chara.pl';

1;
