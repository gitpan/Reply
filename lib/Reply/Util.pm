package Reply::Util;
BEGIN {
  $Reply::Util::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Util::VERSION = '0.24';
}
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw($ident_rx $varname_rx $fq_ident_rx $fq_varname_rx);

# XXX this should be updated for unicode
our $varstart_rx   = qr/[A-Z_a-z]/;
our $varcont_rx    = qr/[0-9A-Z_a-z]/;
our $ident_rx      = qr/${varstart_rx}${varcont_rx}*/;
our $sigil_rx      = qr/[\$\@\%\&\*]/;
our $varname_rx    = qr/$sigil_rx\s*$ident_rx/;
our $fq_ident_rx   = qr/$ident_rx(?:::$varcont_rx+)?/;
our $fq_varname_rx = qr/$varname_rx(?:::$varcont_rx+)?/;

1;

__END__

=pod

=head1 NAME

Reply::Util

=head1 VERSION

version 0.24

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
