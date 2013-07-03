package Reply::Plugin::Autocomplete::Methods;
BEGIN {
  $Reply::Plugin::Autocomplete::Methods::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::Autocomplete::Methods::VERSION = '0.23';
}
use strict;
use warnings;
# ABSTRACT: tab completion for methods

use base 'Reply::Plugin';

use MRO::Compat;
use Package::Stash;
use Scalar::Util 'blessed';


sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{env} = {};
    $self->{package} = 'main';

    return $self;
}

sub lexical_environment {
    my $self = shift;
    my ($name, $env) = @_;

    $self->{env}{$name} = $env;
}

sub package {
    my $self = shift;
    my ($package) = @_;

    $self->{package} = $package;
}

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($invocant, $method) = $line =~ /((?:\$\s*)?[A-Z_a-z][0-9A-Z_a-z:]*)->([A-Z_a-z][0-9A-Z_a-z]*)?$/;
    return unless $invocant;

    $method = '' unless defined $method;

    my $class;
    if ($invocant =~ /^\$/) {
        my $env = {
            (map { %$_ } values %{ $self->{env} }),
            (%{ $self->{env}{defaults} || {} }),
        };
        my $var = $env->{$invocant};
        return unless $var && ref($var) eq 'REF' && blessed($$var);
        $class = blessed($$var);
    }
    else {
        $class = $invocant;
    }

    my @mro = (
        @{ mro::get_linear_isa('UNIVERSAL') },
        @{ mro::get_linear_isa($class) },
    );

    my @results;
    for my $package (@mro) {
        my $stash = eval { Package::Stash->new($package) };
        next unless $stash;

        for my $stash_method ($stash->list_all_symbols('CODE')) {
            next unless index($stash_method, $method) == 0;

            push @results, $stash_method;
        }
    }

    return sort @results;
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::Autocomplete::Methods - tab completion for methods

=head1 VERSION

version 0.23

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Methods]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete method names in Perl
code.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
