#!/usr/bin/perl
package SCM::Version;

use strict;
use Cwd;
use SCM;
use SCM::UTIL;
use Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

@ISA = qw/ SCM Exporter /;

push @EXPORT;


sub new {
    my $class = shift;
    my ($name, $version) = @_;
    my $self = bless {}, $class;

	$self->SUPER::_init_value;

	$self->set_current_version;

	return $self;
}

sub set_current_version {
	my $self = shift;

	return $self->{version} = $self->get_current_version;
}

sub get_current_version {
	my $self = shift;

	my $ver = $self->get_release_version;

	if( $ver == 0 ) {
		$ver = $self->get_base_version;
	}
	else {
		$ver += 1;
	}
	return int( $ver );
}

sub set_current_patch_version {
	my $self = shift;

	return $self->{version} = $self->get_current_patch_version;
}

sub get_current_patch_version {
	my $self = shift;

	my $ver = $self->get_release_version;

	if( $ver == 0 ) {
		return 0;
	}
	$ver += 0.001;

	return $ver;
}

sub set_release_version {
	my $self = shift;

	return $self->{version} = $self->get_release_version;
}

sub get_release_version {
	my $self = shift;

	my @release     = $self->get_release_list;

	if( $#release < 0 ) {
		return 0;
	}
	return $release[$#release];
}

sub set_base_version {
	my $self = shift;

	return $self->{version} = $self->get_base_version;
}

sub get_base_version {
	my $self = shift;
	my $ver;

	open FD, $self->deploy_conf . "/VERSION" || return 0;

	$ver = <FD>;
	chomp $ver;

	if( $ver =~ /^\s*([0-9]+)\.([0-9]+)\s*$/ ) {
		return $self->{version} = $self->verid( $1, $2 );
	}
	return 0;
}

sub version_id {
	my $self = shift;
	
	if( not defined $_[0] ) {
		return $self->{version};
	}
	return $self->{version} = $_[0];
}

sub version_name {
	my $self = shift;
	
	if( not defined $_[0] ) {
		return $self->vername( $self->{version} );
	}
	my $str = $_[0];
	my $level = 0;
	my @v = ( 0, 0, 0, 0 );
	while( $level < 4 ) {
		if( $level < 3 ) {
			if( $str =~/^([0-9]+)\./ ) {
				$v[$level] = int( $1 );
				$str = $';
				$level++;
			}
			elsif( $str =~ /^([0-9]+)$/ ) {
				$v[$level] = int( $1 );
				last;
			}
			else {
				return 0;
			}
		}
		elsif( $level == 3 ) {
			if( $str =~ /^p([0-9]+)$/ ) {
				$v[$level] = int( $1 );
				$level++;
			}
			else {
				return 0;
			}
		}
	}
	return $self->{version} = $self->verid( $v[0], $v[1], $v[2], $v[3] );
}

sub basever {
	my $self = shift;
	my ($vid) = @_;

	$vid -= $vid - int($vid / 1000000) * 1000000;

	return $vid;
}

sub verid {
	my $self = shift;
	my ($v1, $v2, $v3, $p ) = @_;

	return $v1 * 1000000 + $v2 * 1000 + $v3 + $p / 1000;
}

sub vername {
	my $self = shift;
	my ($vid) = @_;

	my $vname = sprintf "%d.%d.%d", int($vid / 1000000), int(($vid/1000)%1000), int($vid%1000);

	$vname .= sprintf ".p%d", int(($vid*1000)%1000) if int(($vid*1000)%1000) > 0;

	return $vname;
}

sub release_info {
	my $self = shift;

	return $self->deploy_conf . "/RELEASE/RELEASE_" . $self->version_name;
}

sub release_dir {
	my $self = shift;

	return $self->home(1) . "/release/v" . $self->version_name;
}

sub get_release_list {
	my $self = shift;
	my @release = ();

	my $basever = $self->get_base_version;

	my $path = $self->deploy_conf . "/RELEASE";

	opendir DH, $path;

	while( ( my $name = readdir( DH ) ) ) {
		if( $name =~ /^RELEASE_([0-9]+)\.([0-9]+)\.([0-9]+)$/ ) {
			push @release, $self->verid($1, $2, $3 ) if ( $basever ==$self->verid($1, $2) );
		}
		if( $name =~ /^RELEASE_([0-9]+)\.([0-9]+)\.([0-9]+)\.p([0-9]+)$/ ) {
			push @release,$self->verid($1, $2, $3, $4) if $basever == $self->verid($1, $2);
		}
	}
	closedir DH;

	return sort @release;
}

1;

