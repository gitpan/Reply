
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "read, eval, print, loop, yay!",
  "AUTHOR" => "Jesse Luehrs <doy at cpan dot org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Reply",
  "EXE_FILES" => [
    "bin/reply"
  ],
  "LICENSE" => "mit",
  "NAME" => "Reply",
  "PREREQ_PM" => {
    "Config::INI::Reader::Ordered" => 0,
    "Data::Dumper" => 0,
    "Devel::LexAlias" => 0,
    "Eval::Closure" => 0,
    "Exporter" => 0,
    "File::HomeDir" => 0,
    "File::Spec" => 0,
    "Getopt::Long" => "2.36",
    "Module::Runtime" => 0,
    "PadWalker" => 0,
    "Scalar::Util" => 0,
    "Term::ANSIColor" => 0,
    "Term::ReadLine" => 0,
    "Time::HiRes" => 0,
    "Try::Tiny" => 0,
    "base" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Test::More" => "0.88"
  },
  "VERSION" => "0.24",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

if ( $^O eq 'MSWin32' ) {
	$WriteMakefileArgs{PREREQ_PM}{'Win32::Console::ANSI'} = '0';
}

WriteMakefile(%WriteMakefileArgs);



