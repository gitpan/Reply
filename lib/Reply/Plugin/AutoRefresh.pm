package Reply::Plugin::AutoRefresh;
BEGIN {
  $Reply::Plugin::AutoRefresh::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::AutoRefresh::VERSION = '0.08';
}
use strict;
use warnings;
# ABSTRACT: automatically refreshes the external code you use

use base 'Reply::Plugin';
use Class::Refresh 0.04;


sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    Class::Refresh->refresh;
    $next->(@args);
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::AutoRefresh - automatically refreshes the external code you use

=head1 VERSION

version 0.08

=head1 SYNOPSIS

  ; .replyrc
  [AutoRefresh]

=head1 DESCRIPTION

This plugin automatically refreshes all loaded modules before every
statement execution. It's useful if you are working on a module in
a file and you want the changes to automatically be loaded in Reply.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
