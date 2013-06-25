package Reply::Plugin::Timer;
BEGIN {
  $Reply::Plugin::Timer::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::Timer::VERSION = '0.12';
}
use strict;
use warnings;
# ABSTRACT: time commands

use base 'Reply::Plugin';

use Time::HiRes qw(gettimeofday tv_interval);


sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{mintime} = $opts{mintime} || 0.01;

    return $self;
}


sub execute {
    my ($self, $next, @args) = @_;

    my $t0 = [gettimeofday];
    my $ret = $next->(@args);
    my $elapsed = tv_interval($t0);

    if ($elapsed > $self->{mintime}) {
        if ($elapsed >= 1) {
            printf "Execution Time: %0.3fs\n", $elapsed
        } else {
            printf "Execution Time: %dms\n", $elapsed * 1000
        }
    }

    return $ret;
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::Timer - time commands

=head1 VERSION

version 0.12

=head1 SYNOPSIS

  ; .replyrc
  [Timer]
  mintime = 0.01

=head1 DESCRIPTION

This plugin prints timer info for results that take longer than C<mintime>.
the default C<mintime> is C<< 0.01 >> seconds.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
