package Reply::Plugin::AutoRefresh;
BEGIN {
  $Reply::Plugin::AutoRefresh::AUTHORITY = 'cpan:DOY';
}
$Reply::Plugin::AutoRefresh::VERSION = '0.35';
use strict;
use warnings;
# ABSTRACT: automatically refreshes the external code you use

use base 'Reply::Plugin';
use Class::Refresh 0.05 ();


sub new {
    my $class = shift;
    my %opts = @_;

    $opts{track_require} = 1
        unless defined $opts{track_require};

    Class::Refresh->import(track_require => $opts{track_require});

    # so that when we load things after this plugin, they get a copy of
    # Module::Runtime which has the call to require() rebound to our overridden
    # copy. if this plugin is loaded first, these should be the only
    # modules loaded so far which load arbitrary user-specified modules.
    Class::Refresh->refresh_module('Module::Runtime');
    Class::Refresh->refresh_module('base');

    return $class->SUPER::new(@_);
}

sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    Class::Refresh->refresh;
    $next->(@args);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Reply::Plugin::AutoRefresh - automatically refreshes the external code you use

=head1 VERSION

version 0.35

=head1 SYNOPSIS

  ; .replyrc
  [AutoRefresh]
  track_require = 1

=head1 DESCRIPTION

This plugin automatically refreshes all loaded modules before every
statement execution. It's useful if you are working on a module in
a file and you want the changes to automatically be loaded in Reply.

It takes a single argument, C<track_require>, which defaults to true.
If this option is set, the C<track_require> functionality from
L<Class::Refresh> will be enabled.

Note that to use the C<track_require> functionality, this module must
be loaded as early as possible (preferably first), so that other
modules correctly see the global override.

=head1 AUTHOR

Jesse Luehrs <doy@tozt.net>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
