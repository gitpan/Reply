package Reply::Plugin::Autocomplete::Methods;
BEGIN {
  $Reply::Plugin::Autocomplete::Methods::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::Autocomplete::Methods::VERSION = '0.25';
}
use strict;
use warnings;
# ABSTRACT: tab completion for methods

use base 'Reply::Plugin';

use MRO::Compat;
use Package::Stash;
use Scalar::Util 'blessed';

use Reply::Util qw($ident_rx $fq_ident_rx $fq_varname_rx);


sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{env} = [];
    $self->{package} = 'main';

    return $self;
}

sub lexical_environment {
    my $self = shift;
    my ($env) = @_;

    push @{ $self->{env} }, $env;
}

sub package {
    my $self = shift;
    my ($package) = @_;

    $self->{package} = $package;
}

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($invocant, $method) = $line =~ /($fq_varname_rx|$fq_ident_rx)->($ident_rx)?$/;
    return unless $invocant;
    # XXX unicode
    return unless $invocant =~ /^[\$A-Z_a-z]/;

    $method = '' unless defined $method;

    my $class;
    if ($invocant =~ /^\$/) {
        # XXX should support globals here
        my $env = {
            map { %$_ } @{ $self->{env} },
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

version 0.25

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
