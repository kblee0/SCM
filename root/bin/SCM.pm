package SCM;

use strict;
use Cwd;
use SCM::UTIL;
use File::Path;
use Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

$VERSION = '1.2.2';
@ISA = qw/ Exporter /;
@EXPORT = qw(home lib bin master deploy _init_value);
push @EXPORT;

sub new {
	my ($class, $home) = @_;
    my $self = {};

    bless ( $self, $class );

	if( defined $home and -d $home ) {
		$ENV{'SCM_HOME'} = $home;
	}
	$self->_init_value();
	
	return $self;
}

sub _init_value {
	my $self = shift;
	
    # read env. variables
    $self->{SCM_ROOT}    = $ENV{'SCM_ROOT'};
    $self->{SCM_MHOME} = $ENV{'SCM_MHOME'};
    $self->{SCM_BHOME} = $ENV{'SCM_BHOME'};
    $self->{SCM_HOME}    = $ENV{'SCM_HOME'};
    $self->{PWD}               = $ENV{ 'PWD' }; # getcwd;

	# subversion repository
	$self->{SCM_REPO_URL}      = $ENV{ 'SCM_REPO_URL' };
	$self->repos( $self->{SCM_REPO_URL} );

    # define MPA(Master Package Area), WPA(Working Package Area)
    $self->{WPA} = $self->{SCM_HOME} . '/pkg';
	$self->{MPA} = $self->{SCM_MHOME} . '/pkg';

    # define Deploy areas
	if( defined $ENV{ 'SCM_DEPLOY' } ) {
		$self->deploy( $ENV{ 'SCM_DEPLOY' } );
	}
	
	# deinfe current work deploy
}


sub _set_deploy_value {
	my $self = shift;
	
	$self->{packages} = ();

	$self->deploy_conf( "$self->{SCM_MHOME}/deploy.conf/" . $self->deploy() . ".d" );
	$self->deploy_cfg( $self->deploy_conf() . "/deploy.cfg" );
	$self->deploy_profile( $self->{SCM_HOME} . '/deploy/.profile' );
	$self->deploy_makefile( $self->{SCM_HOME} . '/deploy/' . $self->deploy() . '/scm_env.inc' );
	$self->_load_deploy_cfg( $self->deploy_cfg );

    # define MDA(Master Deploy Area), WDA(Working Deploy Area)
	$self->_set_deploy_dirs( "MDA", $self->{SCM_MHOME} . '/deploy/' . $self->deploy );
	$self->_set_deploy_dirs( "WDA", $self->{SCM_HOME} . '/deploy/' . $self->deploy );
}

sub _set_deploy_dirs {
	my ( $self, $name, $path, $mkdir ) = @_;
	
	$self->{$name}{bin} = $path . '/bin';
	$self->{$name}{lib} = $path . '/lib';
	$self->{$name}{cfg} = $path . '/cfg';
	$self->{$name}{out} = $path . '/out';
}

sub _make_deploy_dirs {
	my $self = shift;

	mkpath $self->{WDA}{bin}, 0, 0755;
	mkpath $self->{WDA}{lib}, 0, 0755;
	mkpath $self->{WDA}{cfg}, 0, 0755;
	mkpath $self->{WDA}{out}, 0, 0755;
}

sub _load_deploy_cfg {
	my $self = shift;
	my $cfg_file = shift;
	my %packages = ();
	
	debug_print("Load Deploy : CFG = $cfg_file");
	open CFGFD, $self->deploy_cfg() || return 0;
	
	while( (my $line = <CFGFD> ) ) {
		chomp $line;
		if( $line =~ /^#/ ) {
			next;
		}
		elsif( $line =~ /^\s*SKIP_PACKAGES\s*=\s*([^\s]+.*[^\s])\s*$/ ) {
			my @packages = split /\s+/, $1;
			@{$self->{skip_packages}} = @packages;
			debug_print( "skip packages $self->{skip_packages}" );
		}
		elsif( $line =~ /^\s*SKIP_MODULES\s*=\s*([^\s].*[^\s])\s*$/ ) {
			my @modules = split /\s+/, $1;

			@{$self->{skip_modules}} = @modules;
			debug_print( "skip modules $self->{skip_modules}" );
		}
		elsif( $line =~ /^\s*LANG\s*=\s*([^\s].*[^\s])\s*$/ ) {
			$self->{LANG} = $1;
			debug_print( "LANG=$1" );
		}
		elsif( $line =~ /^\s*REPO_URL\s*=\s*([^\s].*[^\s])\s*$/ ) {
			$self->{REPO_URL} = $1;
			if( not $self->master ) {
				$self->repos( $self->{REPO_URL} );
			}
			debug_print( "REPO_URL=$1" );
		}
		elsif( $line =~ /^\s*REPO_MURL\s*=\s*([^\s].*[^\s])\s*$/ ) {
			$self->{REPO_MURL} = $1;
			if( $self->master ) {
				$self->repos( $self->{REPO_MURL} );
			}
			debug_print( "REPO_MURL=$1" );
		}
		elsif( $line =~ /^\s*([^\s]+)\s*=\s*([^\s]+)\s*/ ) {
			my $package = $1;
			my $version = $2;
		
			$self->{packages}{$1} = $2;
			debug_print("Load PKG : $1 = $2");
		}
	}
	close CFGFD;
	
	debug_print("SCM REPO=" . $self->repos );

	return 1;
}

sub scm_version {
	my $self = shift;
	return $VERSION;
}

sub root {
	my $self = shift;
	return $self->{SCM_ROOT};
}

sub make_include {
	my $self = shift;

	return $self->{SCM_ROOT} . '/include';
}

sub deploy {
	my $self = shift;
	
	if( not defined $_[0] ) {
		return $self->{deploy};
	}
	$self->{deploy} = $_[0];
	
	$self->_set_deploy_value( $_[0] );

	if( -f $self->deploy_cfg ) {
		return 1;
	}
	return 0;
}

sub repos {
	$_[0]->{repos} = $_[1] if defined $_[1];
	return $_[0]->{repos};
}

sub deploy_conf {
	$_[0]->{deploy_conf} = $_[1] if defined $_[1];
	return $_[0]->{deploy_conf};
}

sub deploy_cfg {
	$_[0]->{deploy_cfg} = $_[1] if defined $_[1];
	return $_[0]->{deploy_cfg};
}

sub deploy_profile {
	$_[0]->{deploy_profile} = $_[1] if defined $_[1];
	return $_[0]->{deploy_profile};
}

sub deploy_makefile {
	$_[0]->{deploy_makefile} = $_[1] if defined $_[1];
	return $_[0]->{deploy_makefile};
}


sub packages {
	my $self = shift;
	my %packages = $self->{packages};
	
	return keys %{$self->{packages}};
}

sub version {
	my $self = shift;
	my $packge_name = shift;
	
	return $self->{packages}{$packge_name};
}


sub master {
	my $self = shift;

	return $self->{SCM_HOME} eq $self->{SCM_MHOME};
}


sub home {
	my $self = shift;
	my $mhome_ind = shift;
	
	if( $mhome_ind ) {
		return $self->{SCM_MHOME};
	}
	return $self->{SCM_HOME};
}

sub bhome {
	my $self = shift;
	
	return $self->{SCM_BHOME};
}
sub bin {
	my $self = shift;
	my $mhome_ind = shift;
	
	if( $mhome_ind ) {
		return $self->{MDA}{bin};
	}
	return $self->{WDA}{bin};
}

sub lib {
	my $self = shift;
	my $mhome_ind = shift;
	
	if( $mhome_ind ) {
		return $self->{MDA}{lib};
	}
	return $self->{WDA}{lib};
}

sub out {
	my $self = shift;
	my $mhome_ind = shift;
	
	if( $mhome_ind ) {
		return $self->{MDA}{out};
	}
	return $self->{WDA}{out};
}

sub cfg {
	my $self = shift;
	my $mhome_ind = shift;
	
	if( $mhome_ind ) {
		return $self->{MDA}{cfg};
	}
	return $self->{WDA}{cfg};
}

sub pkg {
	my $self = shift;
	my $mhome_ind = shift;
	
	if( $mhome_ind ) {
		return $self->{MPA};
	}
	return $self->{WPA};
}

sub package {
	my $self = shift;
	my $package = shift;
	my $mhome_ind = shift;
	
	if( not defined $self->version($package) ) {
		return undef;
	}
	return sprintf "%s/%s/%s", $self->pkg($mhome_ind), $package, $self->version($package);
}

sub module {
	my $self = shift;
	my $package = shift;
	my $module = shift;
	my $mhome_ind = shift;
	
	if( $module eq '' ) {
		return $self->package( $package, $mhome_ind );
	}
	return sprintf "%s/%s/%s/%s", $self->pkg($mhome_ind), $package, $self->version($package), $module;
}

sub set_deploy_profile {
	my $self = shift;
	my $deploy = shift;

	$self->deploy( $deploy );

	debug_print( "set_deploy_profile $deploy " . $self->deploy_profile );

	my @values = $self->_set_deploy_values( $deploy );
	push @values, $self->_set_deploy_site_values( $deploy );

	$self->_make_deploy_dirs;
	$self->_gen_deploy_profile( @values );
	$self->_gen_deploy_profile_make( @values );
}

sub gen_deploy_profile_make {
	my $self = shift;
	my $deploy = shift;

	$self->deploy( $deploy );

	debug_print( "gen_deploy_profile_make $deploy " . $self->deploy_profile );

	my @values = $self->_set_deploy_values( $deploy );
	push @values, $self->_set_deploy_site_values( $deploy );

	$self->_make_deploy_dirs;
	$self->_gen_deploy_profile_make( @values );
}

sub _gen_deploy_profile {
	my $self = shift;
	my @values = @_;

	open FP, ">" , $self->deploy_profile || return 0;

	print FP "#!/bin/ksh\n";
	print FP "# this file generated by set_deploy\n\n";
	foreach my $def (@values) {
		print FP "export $def\n" if $def ne '';
	}

	# Path
	#printf FP "export PATH=\${PATH}:%s:%s\n", $self->bin, $self->bin(1);
	printf FP "export PATH=%s:%s:\${PATH}\n", $self->bin, $self->bin(1);
	printf FP "export PATH=`path_optimize \${PATH}`\n";
	printf FP "export LD_LIBRARY_PATH=`path_optimize \${LD_LIBRARY_PATH}`\n";

	printf FP "echo\necho current working deployment is %s\necho\n", $self->deploy;

	close FP;

	chmod 0755, $self->deploy_profile;

	return 1;
}

sub _gen_deploy_profile_make {
	my $self = shift;
	my @values = @_;

	open FP, ">" , $self->deploy_makefile || return 0;
	foreach my $def (@values) {
		print FP "$def\n";
	}

	close FP;

	return 1;
}

sub _set_deploy_values {
	my $self = shift;
	my $deploy = shift;

	my @out = ();

	push @out, "SCM_VERSION=" . $VERSION;
	push @out, "SCM_DEPLOY="  . $deploy;
	push @out, "SCM_REPO_URL="  . $self->{REPO_URL};
	push @out, "SCM_REPO_MURL="  . $self->{REPO_MURL};
	push @out, "SCM_WDA_BIN=" . $self->bin;
	push @out, "SCM_WDA_LIB=" . $self->lib;
	push @out, "SCM_WDA_CFG=" . $self->cfg;
	push @out, "SCM_WDA_OUT=" . $self->out;

	foreach my $pkg ($self->packages) {
		push @out, "PACKAGE_$pkg=" . $self->pkg . "/$pkg/" . $self->version( $pkg );
	}

	return @out;
}

### site dependency variable
sub _set_deploy_site_values {
	my $self = shift;
	my $deploy = shift;

	my @out = ();

#	push @out, sprintf "CRAB_HOME=%s/deploy/%s", $self->home, $self->deploy;

	return @out;
}

sub getcw {
	my $self = shift;
	my $path = shift;

	if( not defined $path  ) {
		$path = $self->{PWD};
	}
	my $pat = "/pkg/([\\\w.]+)/[\\\w.]+/([\\\w./]+)/\$";
	if( "$path/" =~ /$pat/ ) {
#		if( $2 eq 'include' ) {
#			return ( $1, '' );
#		}
#		else {
			return ( $1, $2 );
#		}
	}
	$pat = "/pkg/([\\\w.]+)/";
	if( "$path/" =~ /$pat/ ) {
		return ( $1, '' );
	}
	$pat = sprintf "/deploy/%s/out/([\\\w.]+)/(.*)\$", $self->deploy;
	if( "$path" =~ /$pat/ ) {
		return ( $1, $2 );
	}
	$pat = sprintf "/deploy/%s/out/([\\\w.]+)\$", $self->deploy;
	if( "$path" =~ /$pat/ ) {
		return ( $1, '' );
	}
	return ( '', '' );
}

sub check_repository {
	my $self = shift;
	my $path = shift;

	my $cmd = sprintf "sh -c '%s > /dev/null 2>&1'", $self->svn_command( 'ls', $self->repos . "/$path" );
	debug_print( "check_repository $cmd" );
	my $ret = system $cmd;

	if( $ret eq 0 ) {
		return 1;
	}
	return 0;
}

sub skip_build {
	my $self = shift;
	my ($package, $module) = @_;

	if( defined $module ) {
		foreach my $m (@{$self->{skip_modules}}) {
			if( "$package/$module" eq $m ) {
				return 1;
			}
		}
	}
	else {
		foreach my $p (@{$self->{skip_packages}}) {
			if( $package eq $p ) {
				return 1;
			}
		}
	}
	return 0;
}

sub get_build_module {
	my $self = shift;
	my ($package, $module ) = @_;
	my $m;

	foreach my $s ( split( /\//, $module ) ) {
		if( $m eq '' ) {
			$m = $s;
		}
		else {
			$m = "$m/$s";
		}
		if( $self->is_dynamic_module( $package, $m ) ) {
			return $m;
		}
	}
	return $module;
}
sub get_build_sub_modules {
	my $self = shift;
	my ($package, $module ) = @_;

	my @modules = ();

	if( $self->is_dynamic_module( $package, $module ) ) {
		return @modules;
	}

	my @sub_modules = $self->_get_local_sub_modules( $package, $module );

	foreach my $m (@sub_modules) {
		push @modules, $m;
#$m = "$module/$m" if $module ne '';
		my @tmp = $self->get_build_sub_modules($package, $m );
		push @modules, @tmp if $#tmp >= 0;
	}
	return @modules;
}

sub get_dynamic_sub_modules {
	my $self = shift;
	my ($package, $module ) = @_;

	my %modules = ();

	if( not $self->is_dynamic_module( $package, $module ) ) {
		return ();
	}

	foreach my $m ( $self->get_local_sub_modules( $package, $module, 0 ) ) {
		$modules{$m} = 1;
	}
	foreach my $m ( $self->get_local_sub_modules( $package, $module, 1 ) ) {
		$modules{$m} = 1;
	}
	return keys %modules;
}

sub get_module_sources {
	my $self = shift;
	my ($package, $module ) = @_;
	my %srcs = ();

	if( not $self->is_dynamic_module( $package, $module ) ) {
		foreach my $f ( get_dirs( $self->module( $package, $module, 0 ), "f" ) ) {
			$srcs{$f} = 1;
		}
		if( $self->module( $package, $module, 0 ) ne $self->module( $package, $module, 1 ) ) {
			foreach my $f ( get_dirs( $self->module( $package, $module, 1 ), "f" ) ) {
				$srcs{$f} = 1;
			}
		}
		return keys %srcs;
	}
	debug_print( "make src list : " . $self->module( $package, $module, 0 ) );
	foreach my $f ( get_dirs( $self->module( $package, $module, 0 ), "fs" ) ) {
		$srcs{$f} = 1;
	}
	debug_print( "make src list : " . $self->module( $package, $module, 1 ) );
	if( $self->module( $package, $module, 0 ) ne $self->module( $package, $module, 1 ) ) {
		foreach my $f ( get_dirs( $self->module( $package, $module, 1 ), "fs" ) ) {
			$srcs{$f} = 1;
		}
	}
	return keys %srcs;
}

sub get_local_sub_modules {
	my $self = shift;
	my ($package, $module, $mhome_ind ) = @_;;

	my @modules = ();

	my @sub_modules = $self->_get_local_sub_modules( $package, $module, $mhome_ind );
	if( $#sub_modules >= 0 ) {
		foreach my $m (@sub_modules) {
			push @modules, $m;
#$m = "$module/$m" if $module ne '';
			my @tmp = $self->get_local_sub_modules($package, $m, $mhome_ind );
			push @modules, @tmp if $#tmp >= 0;
		}
	}
	return @modules;
}

sub _get_local_sub_modules {
	my $self = shift;
	my ($package, $module, $mhome_ind) = @_;
	my @modules = ();
	my $dh;

	my $path = $self->module( $package, $module, $mhome_ind );

	debug_print( "base path $path" );

	opendir $dh, $path;

	foreach my $dir (readdir $dh) {
		if( $dir eq '.' or $dir eq '..' or $dir eq '.svn' ) {
			next;
		}
		if( -d "$path/$dir" ) {
			if( $module eq '' ) {
				push @modules, $dir;
			}
			else {
				push @modules, "$module/$dir";
			}
		}
	}
	return @modules;
}

sub is_dynamic_module {
	my $self = shift;
	my ($package, $module) = @_;

	my $path = undef;
	my $mpath = undef;
	my $rc = 0;  # false

	$path = $self->module( $package, $module );
	$mpath = $self->module( $package, $module, 1 );

	if( $self->_is_dynamic_module_path( $path ) ) {
		return 1;
	}
	if( (not -f "$path/m_profile") and $self->_is_dynamic_module_path( $mpath ) ) {
		return 1;
	}
	return 0;
}


sub _is_dynamic_module_path {
	my $self = shift;
	my ($path) = @_;

	my $rc = 0;  # false

	if( not -f "$path/m_profile" ) {
		return $rc;
	}
	debug_print( "check $path/m_profile" );
	open MFH, "$path/m_profile";

	while( ( my $line = <MFH> ) ) {
		chomp $line;
		if( not $line =~ /^\s*([^\s]+)\s*=\s*([^\s]+)\s*/ ) {
			next;
		}
		if( $1 eq 'DYNAMIC' and $2 eq 'yes' ) {
			$rc = 1;
			last;
		}
	}
	close MFH;
	return $rc;
}

sub svn {
	my $self = shift;
	my $command = shift;
	my @args = @_;
	my @svnargs = ( '--config-dir', $self->home . '/.subversion' );

	my @svn = ( 'svn', $command, @svnargs, @args );

	if( $command eq 'co' or $command eq 'checkout' ) {
		$ENV{'LANG'} = $self->{LANG} if $self->{LANG};
	}

	debug_print( "@svn" );

	return system( @svn );
}

sub svn_command {
	my $self = shift;
	my $command = shift;
	my @args = @_;
	my @svnargs = ( '--config-dir', $self->home . '/.subversion' );

	my @svn = ( 'svn', $command, @svnargs, @args );

	if( $command eq 'co' or $command eq 'checkout' ) {
		$ENV{'LANG'} = $self->{LANG} if $self->{LANG};
	}

	debug_print( "@svn" );

	return "@svn";
}

1;

__END__
