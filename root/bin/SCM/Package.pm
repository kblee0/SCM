package SCM::Package;
use strict;

use strict;
use Cwd;
use SCM::UTIL;
use Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

@ISA = qw/ SCM Exporter /;
@EXPORT = qw();
push @EXPORT;

sub new {
    my $class = shift;
    my ($name, $version) = @_;
    my $self = bless {}, $class;
    
    $self->SUPER::_init_value;
    
    $self->name( $name );
    $self->version( $version );
    
    $self->_init_value;
    
    return $self;
}

sub _init_value {
}

sub name {
	$_[0]->{name} = $_[1] if defined $_[1];
	return $_[0]->{name};
}

sub version {
	$_[0]->{version} = $_[1] if defined $_[1];
	return $_[0]->{version};
}

# directories
sub pkg {
    my $self = shift;
    my ( $mhome_ind ) = @_;
    
    return $self->SUPER::pkg( $mhome_ind ) . "/$self->{name}/$self->{version}";
}

sub out {
    my $self = shift;
    my ( $module, $mhome_ind ) = @_;
    
    return $self->SUPER::out( $mhome_ind ) . "/$self->{name}/$module";
}

sub lib {
    my $self = shift;
    my ( $module, $mhome_ind ) = @_;
    
    $_ = $module;
    s/\//_/g;

    return $self->SUPER::lib( $mhome_ind ) . "/lib$self->{name}_$_.a";
}

sub include {
    my $self = shift;
    my ( $mhome_ind ) = @_;
    
	$self->pkg( $mhome_ind ) . "/include";
}

# make files
sub make_deploy {
    my $self = shift;
    my( $mhome_ind ) = @_;

    $self->deploy_conf . "/make.inc";
}

sub make_package {
    my $self = shift;
    my( $mhome_ind ) = @_;

    return $self->pkg( $mhome_ind ) . "/make.inc";
}

sub make_module {
    my $self = shift;
    my ( $module, $mhome_ind ) = @_;

   return $self->pkg( $mhome_ind ) . "/$module/make.inc";
}

sub _load_module {
    my $self = shift;
    my ( $mhome_ind ) = @_;
    
    my $self->{modules} = get_dirs( $self->pkg($mhome_ind), "sdt" );
}


sub makefile {
    my $self = shift;
    my $module = shift;
    
    return $self->out( $module ) . "/Makefile";
}

1;
