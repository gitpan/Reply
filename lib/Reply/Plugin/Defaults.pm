package Reply::Plugin::Defaults;
BEGIN {
  $Reply::Plugin::Defaults::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::Defaults::VERSION = '0.09';
}

# XXX Eval::Closure imposes its own hints on things that are eval'ed at the
# moment, but this may be fixed in the future
BEGIN {
    our $default_hints = $^H;
    our $default_hinthash = { %^H };
    our $default_warning_bits = ${^WARNING_BITS};
}

use strict;
use warnings;

use base 'Reply::Plugin';

use Eval::Closure;

sub prompt { "> " }

sub read_line {
    my $self = shift;
    my ($next, $prompt) = @_;

    print $prompt;
    return scalar <>;
}

(my $PREFIX = <<'PREFIX') =~ s/__PACKAGE__/__PACKAGE__/ge;
package main;
BEGIN {
    $^H = $__PACKAGE__::default_hints;
    %^H = %$__PACKAGE__::default_hinthash;
    ${^WARNING_BITS} = $__PACKAGE__::default_warning_bits;
}
PREFIX

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    my @envs = (
        ($args{environment} ? ($args{environment}) : ()),
        values %{ $args{environments} },
    );

    if (@envs) {
        $args{environment} = { map { %$_ } @envs }
    }

    return eval_closure(
        source      => "sub {\n$PREFIX;\n$line\n}",
        terse_error => 1,
        %args,
    );
}

sub execute {
    my $self = shift;
    my ($next, $code, @args) = @_;

    return $code->(@args);
}

sub print_error {
    my $self = shift;
    my ($next, $error) = @_;

    print $error
        if defined $error;
}

sub print_result {
    my $self = shift;
    my ($next, @result) = @_;

    print @result, "\n"
        if @result;
}

1;
