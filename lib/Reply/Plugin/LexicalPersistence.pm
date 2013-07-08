package Reply::Plugin::LexicalPersistence;
BEGIN {
  $Reply::Plugin::LexicalPersistence::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::LexicalPersistence::VERSION = '0.26';
}
use strict;
use warnings;
# ABSTRACT: persists lexical variables between lines

use base 'Reply::Plugin';

use PadWalker 'peek_sub';


sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{env} = {};

    return $self;
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    my ($code) = $next->($line, %args);

    $self->{env} = {
        %{ $self->{env} },
        %{ peek_sub($code) },
    };

    $self->publish('lexical_environment', $self->{env});

    return $code;
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::LexicalPersistence - persists lexical variables between lines

=head1 VERSION

version 0.26

=head1 SYNOPSIS

  ; .replyrc
  [LexicalPersistence]

=head1 DESCRIPTION

This plugin persists the values of lexical variables between input lines. For
instance, with this plugin you can enter C<my $x = 2> into the Reply shell, and
then use C<$x> as expected in subsequent lines.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
