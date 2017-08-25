#!/bin/ksh  -- # -*- perl -*-
eval 'exec perl -S $0 ${1+"$@"}'
if 0;


use lib "$ENV{'SCM_ROOT'}/lib/perl";
use File::Path;
use SCM;
use SCM::Package;
use SCM::UTIL;

sub usage {
	print STDERR @_[0] if defined @_[0];
print STDERR "
USAGE : set_deploy <deploy name>

";
}

my $deploy = $ARGV[0];
my $scm = new SCM;

if( $deploy eq '' ) {
	&usage;
	exit 9;
}

$scm->deploy( $deploy );
if( not -f $scm->deploy_cfg ) {
	&usage( "Deployment does not exist.(deploy = $deploy)\n" );
	exit 9;
}

$scm ->set_deploy_profile( $deploy );

exit 0;

