package Reply::Plugin::Interrupt;
BEGIN {
  $Reply::Plugin::Interrupt::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::Interrupt::VERSION = '0.29';
}
use strict;
use warnings;
# ABSTRACT: allows using Ctrl+C to interrupt long-running lines

use base 'Reply::Plugin';


sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{INT} = sub { die "Interrupted" };
    $next->(@args);
}

sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{INT} = sub { die "Interrupted" };
    $next->(@args);
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::Interrupt - allows using Ctrl+C to interrupt long-running lines

=head1 VERSION

version 0.29

=head1 SYNOPSIS

  ; .replyrc
  [Interrupt]

=head1 DESCRIPTION

This plugin allows you to use Ctrl+C to interrupt long running commands without
exiting the Reply shell entirely.

=head1 AUTHOR

Jesse Luehrs <doy@tozt.net>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
