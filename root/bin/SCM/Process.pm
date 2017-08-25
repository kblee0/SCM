package SCM::Process;

use strict;
use Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

@ISA = qw/ Exporter /;
push @EXPORT;

sub new {
	my ($class, $home) = @_;
    my $self = {};

    bless ( $self, $class );

	return $self;
}

sub print_head {
	my $self = shift;

	print $self->{head} . "\n";
}

sub print {
	my $self = shift;

	my @ps = @_;
	if( $#ps < 0 ) {
		@ps = $self->pslist;
	}

	foreach my $psinfo (@ps) {
		print $psinfo->{text} . "\n";
	}
}

sub get_psinfo {
	my $self = shift;
	my ($pid) = @_;

	foreach my $psinfo ($self->pslist) {
		if( $psinfo->{pid} == $pid ) {
			return $psinfo;
		}
	}
	return ();
}

sub get_psinfobyname {
	my $self = shift;
	my (@argv) = @_;

	foreach my $psinfo ($self->pslist) {
		if( $psinfo->{basename} eq $argv[0] or $psinfo->{argv}->[0] eq $argv[0] ) {
			my $i = 1;
			for( $i = 1; $i <= $#argv; $i++ ) {
				last if $psinfo->{argv}->[$i] ne $argv[$i];
			}
			return $psinfo if $i > $#argv;
		}
	}
	return ();
}

sub get_child_proc {
	my $self = shift;
	my ($pid) = @_;
	my @child = ();

	foreach my $psinfo ($self->pslist) {
		if( $psinfo->{ppid} == $pid ) {
			push @child, $psinfo;
		}
	}
	return @child;
}

sub get_tree_proc {
	my $self = shift;
	my ($pid) = @_;
	my @tree = ();

	@tree = $self->_get_tree_ps( $self->get_psinfo( $pid ) );

	return @tree;
}

sub _get_tree_ps {
	my $self = shift;
	my ($psinfo) = @_;
	my @tree = ($psinfo);

	my @child = $self->get_child_proc( $psinfo->{pid} );

	if( $#child < 0 ) {
		return @tree;
	}

	foreach my $psinfo (@child) {
		push @tree, $self->_get_tree_ps( $psinfo );
	}
	return @tree;
}

sub ps {
	my $self = shift;
	my $user = shift;

	my $cmd;
	my @pslist = ();

	if( defined $user ) {
		$cmd = "ps -fu $user";
	}
	else {
		$cmd = "ps -ef";
	}

	open FD, "$cmd |";
	
	while( my $line = <FD> ) {
		chomp $line;
		if( $line =~ /^\s*(\S+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+|\S+\s+\S+)\s+(\S+)\s+(\S*\d:\d\d)\s+(\S.*)$/ ) {
			;
		}
		elsif( $line =~ /\S+/ ) {
			$self->{head} = $line;
			next;
		}
		else {
			next;
		}
		my @args = $self->_parse_cmd( $8 );

		my %psinfo = (
				'uid'     => $1,
				'pid'     => $2,
				'ppid'    => $3,
				'cpu'     => $4,
				'stime'   => $5,
				'tty'     => $6,
				'time'    => $7,
				'command' => $8,
				'argv'    => \@args,
				'basename'=> $self->_basename( @args[0] ),
				'text'    => $line,
				);

		push @pslist, \%psinfo;
	}
	close FD;

	$self->{ps} = \@pslist;
}

sub pslist {
	my $self = shift;

	return @{$self->{ps}};
}

sub _basename {
	my $self = shift;
	my $cmd = shift;
	if( $cmd =~ /\/([^\/]+)$/ ) {
		return $1;
	}
	return $cmd;
}

sub _parse_cmd {
	my $self = shift;
	my $cmd = shift;

	my @argv = split(/\s+/, $cmd);

	my %shells = (
			"ksh" => 1,
			"sh" => 1,
			"tcsh" => 1,
			"zsh" => 1,
			"bash" => 1,
			"perl" => 1,
			);
	my $basecmd = $self->_basename( $argv[0] );
	my $argv0 = $argv[0];
	my @shellopt = ();

	if( defined $shells{$basecmd} ) {
		while( 1 ) {
			shift @argv;
			if( $#argv == -1 ) {
				@argv = ($argv0, @shellopt);
				last;
			}
			if( $argv[0] =~ /^-/ ) {
				push @shellopt, $argv[0];
			}
			else {
				last;
			}
		}
	}
	return @argv;
}

1;

