#!/usr/bin/perl
package SCM::Help::scmadmin;

use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

$VERSION = '3.05';

@ISA = qw/ Exporter /;
@EXPORT = qw(scmadmin_help);
push @EXPORT;

use strict;
use SCM::Help::scm;

my %admin_help_command = (
	"help"          => \&scmadmin_help_help,
	"addpackage"    => \&scmadmin_help_addpackage,
	"branch"        => \&scmadmin_help_branch,
	"vercopy"       => \&scmadmin_help_vercopy,
	"vercopy_deploy"=> \&scmadmin_help_vercopy_deploy,
	"delpackage"    => \&scmadmin_help_delpackage,
	"refresh"       => \&scmadmin_help_refresh,
	"clean"         => \&scmadmin_help_scm_build_call,
	"make"          => \&scmadmin_help_scm_build_call,
	"make_package"  => \&scmadmin_help_scm_build_call,
	"make_deploy"   => \&scmadmin_help_scm_build_call,
	"diffdeploy"    => \&scmadmin_help_scm_diff_deploy,
	"confirm"       => \&scmadmin_help_confirm,
);

sub scmadmin_help {
	my ($cmd, $subcommand) = @_;

	$subcommand = "help" if not defined $subcommand;

	if( not defined $admin_help_command{ $subcommand } ) {
		printf "admin Help message ÀÛ¼ºÁß\n";
		exit 0;
	}
	$admin_help_command{ $subcommand }->( @_ );
}

sub scmadmin_help_help {
	print <<EOF;
usage: scmadmin <subcommand> [options] [args]
Type 'scmadmin help <subcommand>' for help on a specific subcommand.

Available subcommands:
   addpackage
   branch
   vercopy
   vercopy_deploy
   delpackage
   refresh
   clean
   make
   make_package
   make_deploy
   confirm
   diffdeploy
   help (?, h)

EOF
}

sub scmadmin_help_addpackage {
	print <<EOF;
usage: addpackage PACKAGE VERSION

EOF
}

sub scmadmin_help_branch {
	print <<EOF;
usage: branch PACKAGE CURRENT_VERSION NEW_VERSION

EOF
}

sub scmadmin_help_vercopy {
	print <<EOF;
usage: vercopy PACKAGE SOURCE_VERSION TARGET_VERSION

EOF
}

sub scmadmin_help_vercopy_deploy {
	print <<EOF;
usage: vercopy_deploy SOURCE_DEPLOY TARGET_DEPLOY

EOF
}

sub scmadmin_help_delpackage {
	print <<EOF;
usage: delpackage PACKAGE VERSION

EOF
}

sub scmadmin_help_refresh {
	print <<EOF;
usage: refresh DEPLOY

EOF
}

sub scmadmin_help_scm_build_call {
	my ($cmd, $subcommand) = @_;

	scm_help( @_ );
}

sub scmadmin_help_confirm {
	my ($cmd, $subcommand) = @_;
	print <<EOF;
usage: confirm DEPLOY

EOF
}


sub scmadmin_help_scm_diff_deploy {
	my ($cmd, $subcommand) = @_;
	print <<EOF;
diffdeploy: Display the differences between two revisions of deployment.
usage: diffdeploy DEPLOY OLDREV [NEWREV]

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

