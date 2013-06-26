package Reply::Plugin::ReadLine;
BEGIN {
  $Reply::Plugin::ReadLine::AUTHORITY = 'cpan:DOY';
}
{
  $Reply::Plugin::ReadLine::VERSION = '0.15';
}
use strict;
use warnings;
# ABSTRACT: use Term::ReadLine for user input

use base 'Reply::Plugin';

use File::HomeDir;
use File::Spec;
use Term::ReadLine;


sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{term} = Term::ReadLine->new('Reply');
    my $history = $opts{history_file} || '.reply_history';
    $self->{history_file} = File::Spec->catfile(
        (File::Spec->file_name_is_absolute($history)
            ? ()
            : (File::HomeDir->my_data)),
        $history
    );

    if ($self->{term}->ReadLine eq 'Term::ReadLine::Gnu') {
        $self->{term}->StifleHistory($opts{history_length})
            if defined $opts{history_length} && $opts{history_length} >= 0;
    }

    if (open my $fh, '<', $self->{history_file}) {
        for my $line (<$fh>) {
            chomp $line;
            $self->{term}->addhistory($line);
        }
    }
    else {
        my $e = $!;
        warn "Couldn't open $self->{history_file} for reading: $e"
            if -e $self->{history_file};
    }

    return $self;
}

sub read_line {
    my $self = shift;
    my ($next, $prompt) = @_;

    return $self->{term}->readline($prompt);
}

sub DESTROY {
    my $self = shift;

    return if defined $self->{history_length} && $self->{history_length} == 0;

    # XXX support more later
    return unless $self->{term}->ReadLine eq 'Term::ReadLine::Gnu';

    $self->{term}->WriteHistory($self->{history_file})
        or warn "Couldn't write history to $self->{history_file}";
}

1;

__END__

=pod

=head1 NAME

Reply::Plugin::ReadLine - use Term::ReadLine for user input

=head1 VERSION

version 0.15

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  history_file = '.hist'
  history_length = 100

=head1 DESCRIPTION

This plugin uses L<Term::ReadLine> to read lines from the user. This enables
useful features such as line editing and command history. The history will be
persisted between runs, by default in C<~/.reply_history>, although this is
changeable with the C<history_file> option. To limit the number of lines
written to this file, you can use the C<history_length> option. Setting a
C<history_length> of C<0> will disable writing history to a file entirely.

NOTE: you probably want to install a reasonable L<Term::ReadLine> backend in
order for this plugin to be very useful. L<Term::ReadLine::Gnu> is highly
recommended if possible.

=head1 AUTHOR

Jesse Luehrs <doy at cpan dot org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Jesse Luehrs.

This is free software, licensed under:

  The MIT (X11) License

=cut
