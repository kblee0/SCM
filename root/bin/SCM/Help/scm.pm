#!/usr/bin/perl
package SCM::Help::scm;

use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

$VERSION = '3.05';

@ISA = qw/ Exporter /;
@EXPORT = qw(scm_help gmake_help);
push @EXPORT;

use strict;

my %help_command = (
	"help"            => \&scm_help_help,
	"co"              => \&scm_help_checkout,
	"checkout"        => \&scm_help_checkout,
	"get"             => \&scm_help_get,
	"diffpackage"     => \&scm_help_diffpackage,
	"make"            => \&scm_help_make,
	"make_deploy"     => \&scm_help_make_deploy,
	"make_package"    => \&scm_help_make_package,
	"commit_package"  => \&scm_help_commit_package,
	"status_package"  => \&scm_help_status_package,
	"refresh"         => \&scm_help_refresh,
	"clean"           => \&scm_help_clean,
);

sub scm_help {
	my ($cmd, $subcommand) = @_;

	$subcommand = "help" if not defined $subcommand;

	if( not defined $help_command{ $subcommand } ) {
		printf "Help message ÀÛ¼ºÁß\n";
		exit 0;
	}
	$help_command{ $subcommand }->( @_ );
}

sub scm_help_help {
	my $ver = "1.0.0";
	print <<EOF;
usage: scm <subcommand> [options] [args]
SCM command-line client, version $ver.
Type 'scm help <subcommand>' for help on a specific subcommand.

Most subcommands take file and/or directory arguments, recursing
on the directories.  If no arguments are supplied to such a
command, it recurses on the current directory (inclusive) by default.

Available subcommands:
   add
   blame
   cat
   checkout (co)
   get
   cleanup
   commit (ci)
   commit_package
   delete (del, remove, rm)
   diff (di)
   help (?, h)
   list (ls)
   log
   move (mv, rename, ren)
   revert
   status (stat, st)
   status_package
   diffpackage
   update (up)
   make
   make_package
   make_deploy
   refresh
   clean
   lock
   unlock

SCM is a tool for version control.
EOF
}

sub scm_help_checkout {
	print <<EOF;
checkout (co): Check out a working copy from a repository.
usage: checkout ... [PATH]

  If PATH is omitted, the current directory will be used as
  the destination. If multiple PATHs are given each will be checked
  out into a sub-directory of PATH.

Valid options:
  -r [--revision] arg      : ARG
                             A revision argument can be one of:
                                NUMBER       revision number
                                '{' DATE '}' revision at start of the date
                                'HEAD'       latest in repository
                                'BASE'       base rev of item's working copy
                                'COMMITTED'  last commit at or before BASE
                                'PREV'       revision just before COMMITTED

EOF
}

sub scm_help_get {
	print <<EOF;
get: get files from a repository.
usage: get -r arg [-f] [files]

  If PATH is omitted, the current directory will be used as
  the destination.

Valid options:
  -r arg      : ARG (some commands also take ARG1:ARG2 range)
                A revision argument can be one of:
                   NUMBER       revision number
                   '{' DATE '}' revision at start of the date
                   'HEAD'       latest in repository
                   'BASE'       base rev of item's working copy
                   'COMMITTED'  last commit at or before BASE
                   'PREV'       revision just before COMMITTED
  -f          : force operation to run

EOF
}


sub gmake_help {
	my $msg = <<EOF;
Options:
  -b, -m                      Ignored for compatibility.
  -d                          Print lots of debugging information.
  --debug[=FLAGS]             Print various types of debugging information.
  -e, --environment-overrides
                              Environment variables override makefiles.
  -h, --help                  Print this message and exit.
  -i, --ignore-errors         Ignore errors from commands.
  -j [N], --jobs[=N]          Allow N jobs at once; infinite jobs with no arg.
  -k, --keep-going            Keep going when some targets can't be made.
  -l [N], --load-average[=N], --max-load[=N]
                              Don't start multiple jobs unless load is below N.
  -n, --just-print, --dry-run, --recon
                              Don't actually run any commands; just print them.
  -o FILE, --old-file=FILE, --assume-old=FILE
                              Consider FILE to be very old and don't remake it.
  -p, --print-data-base       Print make's internal database.
  -q, --question              Run no commands; exit status says if up to date.
  -r, --no-builtin-rules      Disable the built-in implicit rules.
  -R, --no-builtin-variables  Disable the built-in variable settings.
  -s, --silent, --quiet       Don't echo commands.
  -S, --no-keep-going, --stop
                              Turns off -k.
  -t, --touch                 Touch targets instead of remaking them.
  -v, --version               Print the version number of make and exit.
  -w, --print-directory       Print the current directory.
  --no-print-directory        Turn off -w, even if it was turned on implicitly.
  -W FILE, --what-if=FILE, --new-file=FILE, --assume-new=FILE
                              Consider FILE to be infinitely new.
  --warn-undefined-variables  Warn when an undefined variable is referenced.
EOF
	return $msg;
}

sub gmake_help__ {
	my @help = `gmake --help`;
	my $msg;

	while( 1 ) {
		if( $help[0] =~ /^Options:/ ) {
			last;
		}
		shift @help;
		last if $#help < 0;
	}
	foreach my $line (@help) {
		$msg .= $line;
	}
	return $msg;
}

sub scm_help_make {
	my $help = &gmake_help;

	print <<EOF;
usage : make [options] [target] ...

$help
EOF
}

sub scm_help_make_package {
	my $help = &gmake_help;

	print <<EOF;
usage : make_package DEPLOY PACKAGE [options] [target] ...

$help
EOF
}

sub scm_help_make_deploy {
	my $help = &gmake_help;

	print <<EOF;
usage : make_deploy DEPLOY [options] [target] ...

$help
EOF
}

sub scm_help_commit_package {
	print <<EOF;
commit_package : Send changes from your working package sources files to the repository.

usage: commit_package [DEPLOY] PACKAGE

  A log message must be provided, but it can be empty.  If it is not
  given by a --message or --file option, an editor will be started.
  If any targets are (or contain) locked items, those will be
  unlocked after a successful commit.

Valid options:
  -m [--message] arg       : specify log message ARG
  -F [--file] arg          : read log message from file ARG

EOF
}

sub scm_help_status_package {
	print <<EOF;
status_package : Print the status of working package sources files
usage: status_package [PATH...]

  The first six columns in the output are each one character wide:
    First column: Says if item was added, deleted, or otherwise changed
      ' ' no modifications
      'A' Added
      'C' Conflicted
      'D' Deleted
      'I' Ignored
      'M' Modified
      'R' Replaced
      'X' item is unversioned, but is used by an externals definition
      '?' item is not under version control
      '!' item is missing (removed by non-svn command) or incomplete
      '~' versioned item obstructed by some item of a different kind
    Second column: Modifications of a file's or directory's properties
      ' ' no modifications
      'C' Conflicted
      'M' Modified
    Third column: Whether the working copy directory is locked
      ' ' not locked
      'L' locked
    Fourth column: Scheduled commit will contain addition-with-history
      ' ' no history scheduled with commit
      '+' history scheduled with commit
    Fifth column: Whether the item is switched relative to its parent
      ' ' normal
      'S' switched
    Sixth column: Repository lock token
      (without -u)
      ' ' no lock token
      'K' lock token present
      (with -u)
      ' ' not locked in repository, no lock token
      'K' locked in repository, lock toKen present
      'O' locked in repository, lock token in some Other working copy
      'T' locked in repository, lock token present but sTolen
      'B' not locked in repository, lock token present but Broken

  Example output:
    scm status_package NPFM
    M      /users/crabdev/kblee/pkg/NPFM/v010/PFM/CM/NFW_Common.cpp
    M      /users/crabdev/kblee/pkg/NPFM/v010/PFM/CM/AP_Defines.hpp
    ?      /users/crabdev/kblee/pkg/NPFM/v010/PFM/UA/tags
    M      /users/crabdev/kblee/pkg/NPFM/v010/RDLIB/application/NLCConfig.cpp
    ?      /users/crabdev/kblee/pkg/NPFM/v010/RDLIB/system/.NLCProcess.cpp.swp
    A      /users/crabdev/kblee/pkg/NPFM/v010/RDLIB/common/NEW/make.inc
    ?      /users/crabdev/kblee/pkg/NPFM/v010/RDLIB/common/NEW/test
    M      /users/crabdev/kblee/pkg/NPFM/v010/make.inc

EOF
}

sub scm_help_refresh {
	print <<EOF;
Check out all modules in PACKAGE from a repository.

usage : refresh DEPLOY PACKAGE

EOF
}


sub scm_help_clean {
	print <<EOF;
Remove all output objects of make command.

usage : clean [DEPLOY]

EOF
}

sub scm_help_diffpackage {
	print <<EOF;
diffpackage: Display the differences between two revisions of package.
usage: diffpackage DEPLOY PACKAGE OLDREV [NEWREV]

Valid options:
  OLDREV, NEWREV : A revision argument can be one of:
                      NUMBER       revision number
                      '{' DATE '}' revision at start of the date
                      'HEAD'       latest in repository
                      'BASE'       base rev of item's working copy
                      'COMMITTED'  last commit at or before BASE
                      'PREV'       revision just before COMMITTED

EOF
}
1;

