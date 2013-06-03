package Reply::Plugin::FancyPrompt;
BEGIN {
  $Reply::Plugin::FancyPrompt::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::FancyPrompt::VERSION = '0.02';
}
use strict;
use warnings;
# ABSTRACT: provides a more informative prompt

use base 'Reply::Plugin';


sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{counter} = 0;
    return $self;
}

sub prompt {
    my $self = shift;
    my ($next) = @_;
    return $self->{counter} . $next->();
}

sub loop {
    my $self = shift;
    $self->{counter}++;
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::FancyPrompt - provides a more informative prompt

=head1 VERSION

version 0.02

=head1 SYNOPSIS

  ; .replyrc
  [FancyPrompt]

=head1 DESCRIPTION

This plugin enhances the default Reply prompt. Currently, the only difference
is that it includes a counter of the number of lines evaluated so far in the
current session.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
