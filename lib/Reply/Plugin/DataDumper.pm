package Reply::Plugin::DataDumper;
BEGIN {
  $Reply::Plugin::DataDumper::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::DataDumper::VERSION = '0.02';
}
use strict;
use warnings;
# ABSTRACT: format results using Data::Dumper

use base 'Reply::Plugin';

use Data::Dumper;


sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return Dumper(@result);
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::DataDumper - format results using Data::Dumper

=head1 VERSION

version 0.02

=head1 SYNOPSIS

  ; .replyrc
  [DataDumper]

=head1 DESCRIPTION

This plugin uses L<Data::Dumper> to format results.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
