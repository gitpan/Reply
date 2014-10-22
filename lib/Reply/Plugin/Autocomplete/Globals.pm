package Reply::Plugin::Autocomplete::Globals;
BEGIN {
  $Reply::Plugin::Autocomplete::Globals::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::Autocomplete::Globals::VERSION = '0.18';
}
use strict;
use warnings;
# ABSTRACT: tab completion for global variables

use base 'Reply::Plugin';

use Package::Stash;


sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    return $self;
}

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($maybe_var) = $line =~ /([\$\@\%\&\*]\s*[0-9A-Z_a-z:]*)$/;
    return unless $maybe_var;
    $maybe_var =~ s/\s+//g;

    my ($sigil, $rest) = $maybe_var =~ /(.)(.*)/;

    my @parts = split '::', $rest, -1;
    return if grep { /:/ } @parts;
    return if $parts[0] =~ /^[0-9]/;

    my $var_prefix = pop @parts;

    my $stash_name = join('::', @parts);
    my $stash = eval {
        Package::Stash->new(@parts ? $stash_name : 'main')
    };
    return unless $stash;

    my @symbols = map { s/^(.)main::/$1/; $_ } _recursive_symbols($stash);

    my $prefix = $stash_name
        ? $stash_name . '::' . $var_prefix
        : $var_prefix;

    my @results;
    for my $global (@symbols) {
        my ($global_sigil, $global_name) = $global =~ /(.)(.*)/;
        next unless index($global_name, $prefix) == 0;

        # this is weird, not sure why % gets stripped but not $ or @
        if ($sigil eq $global_sigil) {
            push @results, $sigil eq '%' ? $global : $global_name;
        }
        elsif ($global_sigil eq '@' && $sigil eq '$') {
            push @results, "$global_name\[";
        }
        elsif ($global_sigil eq '%') {
            push @results, "$global_name\{";
        }
    }

    return @results;
}

sub _recursive_symbols {
    my ($stash) = @_;

    my $stash_name = $stash->name;

    my @symbols;
    for my $name ($stash->list_all_symbols) {
        if ($name =~ s/::$//) {
            my $next = Package::Stash->new(join('::', $stash_name, $name));
            next if $next->namespace == $stash->namespace;
            push @symbols, _recursive_symbols($next);
        }
        else {
            push @symbols, "\$${stash_name}::$name"
                if $stash->has_symbol("\$$name");
            push @symbols, "\@${stash_name}::$name"
                if $stash->has_symbol("\@$name");
            push @symbols, "\%${stash_name}::$name"
                if $stash->has_symbol("\%$name");
            push @symbols, "\&${stash_name}::$name"
                if $stash->has_symbol("\&$name");
            push @symbols, "\*${stash_name}::$name"
                if $stash->has_symbol($name);
        }
    }

    return @symbols;
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::Autocomplete::Globals - tab completion for global variables

=head1 VERSION

version 0.18

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Globals]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete global variables in
Perl code.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
