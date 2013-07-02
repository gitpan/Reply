package Reply::Plugin::DataDump;
BEGIN {
  $Reply::Plugin::DataDump::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::DataDump::VERSION = '0.22';
}
use strict;
use warnings;
# ABSTRACT: format results using Data::Dump

use base 'Reply::Plugin';

use Data::Dump 'pp';


sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return @result ? pp(@result) : ();
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::DataDump - format results using Data::Dump

=head1 VERSION

version 0.22

=head1 SYNOPSIS

  ; .replyrc
  [DataDumper]

=head1 DESCRIPTION

This plugin uses L<Data::Dump> to format results.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
