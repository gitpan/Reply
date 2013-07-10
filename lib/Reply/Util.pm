package Reply::Util;
BEGIN {
  $Reply::Util::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Util::VERSION = '0.27';
}
use strict;
use warnings;

BEGIN {
    if ($] < 5.010) {
        require MRO::Compat;
    }
    else {
        require mro;
    }
}

use Package::Stash;
use Scalar::Util 'blessed';

use Exporter 'import';
our @EXPORT_OK = qw(
    $ident_rx $varname_rx $fq_ident_rx $fq_varname_rx
    methods all_packages
);

# XXX this should be updated for unicode
our $varstart_rx   = qr/[A-Z_a-z]/;
our $varcont_rx    = qr/[0-9A-Z_a-z]/;
our $ident_rx      = qr/${varstart_rx}${varcont_rx}*/;
our $sigil_rx      = qr/[\$\@\%\&\*]/;
our $varname_rx    = qr/$sigil_rx\s*$ident_rx/;
our $fq_ident_rx   = qr/$ident_rx(?:::$varcont_rx+)*/;
our $fq_varname_rx = qr/$varname_rx(?:::$varcont_rx+)*/;

sub methods {
    my ($invocant) = @_;

    my $class = blessed($invocant) || $invocant;

    my @mro = (
        @{ mro::get_linear_isa('UNIVERSAL') },
        @{ mro::get_linear_isa($class) },
    );

    my @methods;
    for my $package (@mro) {
        my $stash = eval { Package::Stash->new($package) };
        next unless $stash;
        push @methods, $stash->list_all_symbols('CODE');
    }

    return @methods;
}

sub all_packages {
    my ($root) = @_;
    $root ||= \%::;

    my @packages;
    for my $fragment (grep { /::$/ } keys %$root) {
        next if ref($root) && $root == \%:: && $fragment eq 'main::';
        push @packages, (
            $fragment,
            map { $fragment . $_ } all_packages($root->{$fragment})
        );
    }

    return map { s/::$//; $_ } @packages;
}

__END__

=pod

=head1 NAME

Reply::Util

=head1 VERSION

version 0.27

=for Pod::Coverage   methods
  all_packages

1;

=head1 AUTHOR

Jesse Luehrs <doy@tozt.net>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
