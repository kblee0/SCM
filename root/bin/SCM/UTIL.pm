package SCM::UTIL;

use strict;
use Exporter;
use POSIX qw(getuid strftime);
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

$VERSION = '3.05';

@ISA = qw/ Exporter /;
@EXPORT = qw(debug_print debug_mode debug_mode_changable get_dirs get_file_user getusername strtime daemon_init);
push @EXPORT;

our $debug_mode = 0;
our $debug_mode_changable = 1;

sub debug_mode_changable {
	$debug_mode_changable = $_[0];
}

sub debug_mode {
	if( $debug_mode_changable eq 1 ) {
		$debug_mode = $_[0];
	}
}

sub debug_print {
	if( $debug_mode ne 0 ) {
		print "[DEBUG] ";
		print @_;
		print "\n";
    }
}

# get_dir
#    $path : base directory
#    $opts :
#         d - directory
#         f  - files
#         s  - sub directories
#         p - Full path
sub get_dirs {
	my ( $path, $opts ) = @_;
	my ( $opt_d, $opt_f, $opt_s, $opt_t ) = ();
	my $base = '';
	
	$opt_d = 1 if $opts =~ /d/;
	$opt_f = 1 if $opts =~ /f/;
	$opt_s = 1 if $opts =~ /s/;
	$opt_t = 1 if $opts =~ /t/;
	$base = $path . '/' if $opts =~ /p/;
	
	return _read_dirs($path, $base, $opt_d, $opt_f, $opt_s );
}

# internal function of get_dirs
sub _read_dirs {
	my ( $path, $base, $opt_d, $opt_f, $opt_s, $opt_t ) = @_;
	my @out = ();
	my $dh;
	opendir $dh, $path;
	
	while( ( my $name = readdir( $dh ) ) ) {
		if( $name eq '.' or $name eq '..' or $name eq '.svn' ) {
			next;
		}
		my $file = "$path/$name";
		if( -f $file ) {
			push @out, $base . $name if $opt_f;
		}
		elsif( -d $file ) {
			push @out, $base . $name if $opt_d and $opt_t;
			if( $opt_s ) {
				push @out, &_read_dirs( $file, "$base$name/", $opt_d, $opt_f, $opt_s, $opt_t );
			}
			push @out, $base . $name if $opt_d and not $opt_t;
		}
	}
	closedir $dh;
	
	return @out;
}

sub get_file_user {
	my ($path) = @_;

	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = stat($path);

	getpwuid($uid);
}

sub getusername {
	my $uid   = getuid();
	my @login = getpwuid( $uid );

	return $login[0];
}

sub strtime {
	my ($format,$time) = @_;
	$time = time if not defined $time;

	my @t = localtime( $time );

	return strftime( $format, $t[0], $t[1], $t[2], $t[3], $t[4], $t[5], $t[6], $t[7], $t[8] );
}

##---------------------------------------------------------------------------##
##	Init(): Become a daemon.
##
sub daemon_init {
	use Carp;

	my $oldmode = shift || 0;
	my($pid, $sess_id, $i);

## Fork and exit parent
	if ($pid = Fork()) { exit 0; }

## Detach ourselves from the terminal
	croak "Cannot detach from controlling terminal" unless $sess_id = POSIX::setsid();

## Prevent possibility of acquiring a controling terminal
	if (!$oldmode) {
		$SIG{'HUP'} = 'IGNORE';
		if ($pid = Fork()) { exit 0; }
	}

## Change working directory
#	chdir "/";

## Clear file creation mask
#	umask 0;

## Close open file descriptors
#	foreach $i (0 .. OpenMax) { POSIX::close($i); }

## Reopen stderr, stdout, stdin to /dev/null
	open(STDIN,  "+>/dev/null");
#    open(STDOUT, "+>&STDIN");
#    open(STDERR, "+>&STDIN");

	$oldmode ? $sess_id : 0;
}

##---------------------------------------------------------------------------##
##	Fork(): Try to fork if at all possible.  Function will croak
##	if unable to fork.
##
sub Fork {
	use POSIX;

	my($pid);
FORK: {
		  if (defined($pid = fork)) {
			  return $pid;
		  } elsif ($! =~ /No more process/) {
			  sleep 5;
			  redo FORK;
		  } else {
			  croak "Can't fork: $!";
		  }
	  }
}


1;

__END__
