package Reply::Plugin::LexicalPersistence;
BEGIN {
  $Reply::Plugin::LexicalPersistence::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::LexicalPersistence::VERSION = '0.02';
}
use strict;
use warnings;
# ABSTRACT: persists lexical variables between lines

use base 'Reply::Plugin';

use Lexical::Persistence;


sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{env} = Lexical::Persistence->new;
    return $self;
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    my %c = %{ $self->{env}->get_context('_') };

    $args{environment} ||= {};
    $args{environment} = {
        %{ $args{environment} },
        (map { $_ => ref($c{$_}) ? $c{$_} : \$c{$_} } keys %c),
    };
    my ($code) = $next->($line, %args);
    $code = $self->_fixup_code($code, \%c);
    return $self->{env}->wrap($code);
}

# XXX this is maybe a bug in Lexical::Persistence - it clears variables that
# aren't in its context, regardless of if they may have been set elsewhere
sub _fixup_code {
    my $self = shift;
    my ($code, $context) = @_;

    require PadWalker;
    require Devel::LexAlias;

    my $pad = PadWalker::peek_sub($code);
    my %restore;
    for my $var (keys %$pad) {
        next unless $var =~ /^\$\@\%./;
        next if exists $context->{$var};
        $restore{$var} = $pad->{$var};
    }

    $self->{code} = $code;

    return sub {
        my $code = shift;
        for my $var (keys %restore) {
            Devel::LexAlias::lexalias($code, $var, $restore{$var});
        }
        $code->(@_);
    };
}

# XXX can't just close over $code, because it will also be cleared by the same
# bug! we have to pass it as a parameter instead
sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    $next->(delete $self->{code}, @args);
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::LexicalPersistence - persists lexical variables between lines

=head1 VERSION

version 0.02

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
