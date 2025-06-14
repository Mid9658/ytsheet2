use strict;
use utf8;

# Nechronica 専用サブルーチン

### select要素生成 --------------------------------------------------
#   optionNc('name', @list)
#   @list: 'value|<label>' ...
sub optionNc {
  my $name = shift;
  my $text = '<option value=""></option>';
  foreach my $i (@_) {
    my $value = $i;
    my $view;
    if($value =~ s/^label=//){
      $text .= '<optgroup label="'.$value.'">';
      next;
    }
    elsif($value eq 'close_group') {
      $text .= '</optgroup>';
      next;
    }
    if($value =~ s/\|\<(.*?)\>$//){ $view = $1 } else { $view = $value }
    $text .= '<option value="'.$value.'"'.($::pc{$name} eq $value ? ' selected':'').'>'.$view.'</option>';
  }
  return $text;
}

1;
