package Reply::Plugin::Autocomplete::Packages;
BEGIN {
  $Reply::Plugin::Autocomplete::Packages::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::Autocomplete::Packages::VERSION = '0.26';
}
use strict;
use warnings;
# ABSTRACT: tab completion for package names

use base 'Reply::Plugin';

use Module::Runtime '$module_name_rx';


sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    # $module_name_rx does not permit trailing ::
    my ($before, $package_fragment) = $line =~ /(.*?)(${module_name_rx}:?:?)$/;
    return unless $package_fragment;
    return if $before =~ /->\s*$/; # method call
    return if $before =~ /[\$\@\%\&\*]\s*$/;

    my $file_fragment = $package_fragment;
    $file_fragment =~ s{::}{/}g;

    my $re = qr/^\Q$file_fragment/;

    my @results;
    for my $inc (keys %INC) {
        if ($inc =~ $re) {
            $inc =~ s{/}{::}g;
            $inc =~ s{\.pm$}{};
            push @results, $inc;
        }
    }

    push @results,
        grep m/^\Q$package_fragment/,
        @{$self->{moar_packages}||=[]};

    return @results;
}

# listen for events from the Packages plugin, for its wise wisdom
# can teach us about packages that are not in %INC
sub package {
    my $self = shift;
    my ($pkg) = @_;
    push @{$self->{moar_packages}||=[]}, $pkg;
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::Autocomplete::Packages - tab completion for package names

=head1 VERSION

version 0.26

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Packages]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete package names in Perl
code.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
