package SCM::Ini;

use 5.006;
use strict;
use warnings;

require Exporter;
#use AutoLoader qw(AUTOLOAD);

use overload qw{""} => \&_to_string;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw( );

our $VERSION = '0.08';

# Preloaded methods go here.

#
# ------------------------------------------------------------------------------------------------------- structural methods -----
#

sub new {
    my($class,$initialiser) = @_;
    my $self = { _settings => undef,
								 _settingsfile => undef
		};
    bless $self,ref $class || $class;
    $self->init($initialiser);
    return $self;
}

sub init {
	my($self,$settingsfile) = @_;	
	return if($settingsfile eq '');
	$self->{_settings} = $self->read_settings($settingsfile);
	$self->{_settingsfile} = $settingsfile;
}


#
# --------------------------------------------------------------------------------------------------------- accessor methods -----
#

sub get_all_settings {
	my($self) = @_;
	# Make sure we don't crash and burn trying to return a hash from an undef reference
	return undef unless(defined($self->{_settings}));
	# Return the settings as a hash in array contect and a hash reference in scalar context
	if(wantarray){
		return %{$self->{_settings}};
	}else{
		return $self->{_settings};
	}
}

sub get_entry {
	my($self,$entryname) = @_;
	if( not defined($entryname) ) {
		return undef;
	}
	if(defined(${$self->{_settings}}{$entryname})){
		if(wantarray){
			return(%{${$self->{_settings}}{$entryname}});
		}else{
			return(${$self->{_settings}}{$entryname});
		}
	}else{
		return undef;
	}
}

sub get_entry_setting {
	my($self,$entryname,$settingname,$default) = @_;

	if( not defined($entryname) or not defined($settingname) ) {
		return undef;
	}
	# Return undef if the requested entry doesn't exist
	my %entry = ();
	return(undef) unless(%entry = $self->get_entry($entryname));
	if(defined($entry{$settingname})){
		return $entry{$settingname};
	}else{
		return $default;
	}
}

sub set_all_settings {
	my($self,%allsettings) = @_;
	return %{$self->{_settings}} = %allsettings;
}

sub set_entry {
	my($self,$entryname,%entry) = @_;
	return(%{${$self->{_settings}}{$entryname}} = %entry);
}

sub set_entry_setting {
	my($self,$entryname,$settingname,$setting) = @_;
	if( not defined($settingname) ) {
		return undef;
	}
	if( not defined($setting) ) {
		$setting = '';
	}
	return(${${$self->{_settings}}{$entryname}}{$settingname} = $setting);
}

sub get_entry_names {
	my($self) = @_;
	return sort(keys(%{$self->{_settings}}));
}

#
# ------------------------------------------------------------------------------------------------ (un)serialisation methods -----
#

##################################################
#%name: _to_string
#%syntax: _to_string
#%summary: Recursively generates a string representation of the settings hash
#%returns: a string in .ini format 

sub _to_string{
	my($self) = @_;
	return _dumpobject('',$self->{_settings});
}

##################################################
#%name: _dumpobject
#%syntax: _dumpobject(<$objectcaption>,<$objectref>,[<@parentobjectcaptions>])
#%summary: Recursively generates a string representation of the object referenced
#          by $objectref
#%returns: a string representation of the object

sub _dumpobject{
	my($name,$obj,@parents) = @_;
	my @result = ();
	if(ref($obj) eq 'HASH'){
		unless($name eq ''){
			push(@parents,"$name");
			push(@result,'[' . join('::',@parents) . ']');
		}
		while(my($key,$val) = each(%{$obj})){
			push(@result,_dumpobject($key,$val,@parents));
		}
	}elsif(ref($obj) eq 'SCALAR'){
		push(@result,"$name = ${$obj}");
	}elsif(ref($obj) eq 'ARRAY'){
		push(@parents,"$name");
		push(@result,'[' . join('::',@parents) . ']');
		for(my $i = 0;scalar(@{$obj});$i++){
			push(@result,_dumpobject($i,${$obj}[$i],@parents));
		}
	}else{
		push(@result,"$name = $obj");
	}
	return(join("\n",@result));
}

##################################################
#%name: read_settings
#%syntax: read_settings(<$settingsfilename>)
#%summary: Reads the projects to keep track of
#%returns: a hash of $projectkey:$projectlabel

sub read_settings{
	my ($self,$settingdata) = @_;
	my @conflines;
	if(ref($settingdata) eq 'ARRAY'){
		@conflines = @{$settingdata};
	}else{
		my $settingsfile = $settingdata;
		# Read in the ini file we want to use
		# Probably not a good idea to die on error at this
		# point, but that's what we've got for the moment
		open(SETTINGS,$settingsfile) || die("Failed to open ini file ($settingsfile) for reading\n");
		@conflines = <SETTINGS>;
		close(SETTINGS);
	}
	my $settings = _parse_settings_file(@conflines);
	return($settings);
}

##################################################
#%name: _parse_settings_file
#%syntax: _parse_settings_file(<@settings>)
#%summary: Reads the projects to keep track of
#%returns: a hash of $projectkey:$projectlabel

sub _parse_settings_file{
	my %result = ();
	my ($entry,$subentry) = ('','');
	chomp(@_);
	foreach(@_){
		# Get rid of starting/ending whitespace
		s/^\s*(.*)\s*$/$1/;
		
		# Delete comments
		#($_) = split(/[;#]/);
		next if( /^[;#]/ );
		# Skip if there's no data
		next if((! defined($_)) || $_ eq '');
		
		/^\s*(.*?)\s*=\s*['"]?(.*)['"]?\s*/ && do {
			my($key,$val) = ($1,$2);

#			next if($key eq '' || $val eq '');
			next if($key eq '');
			if(! $subentry){
				${$result{$entry}}{$key} = $val;
			}else{
				${$result{$entry}}{$subentry}{$key} = $val;
			}
			next;
		};
		# Select a new entry if this is such a line
		/\[(.*?)\]/ && do{
			
			$_ = $1;
			($entry,$subentry) = split('::');
			if(! $subentry){
				$result{$entry} = {};
			}elsif($result{$entry}){
				$result{$entry}{$subentry} = {};
			}
			next;
		};
	}
	return(\%result);
}

sub write_settings {
	my ($self,$settingdata) = @_;

	open( SETTINGS, ">$settingdata" ) || die ("Failed to open ini file ($settingdata) for writting\n");
	
	print SETTINGS $self->_to_string . "\n";
	
	close( SETTINGS );
}

#
# ---------------------------------------------------------------------------------------------------------- utility methods -----
#


sub expand_tilde {
	defined($ENV{'HOME'}) && do {
		$_[0] =~ s/^~/$ENV{'HOME'}/;
	};
	return $_[0];
}


# We provide a DESTROY method so that the autoloader
# doesn't bother trying to find it.
sub DESTROY { }

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
=head1 NAME

Configfile::Ini - Perl extension for handling ini style files

=head1 SYNOPSIS

 use Configfile::Ini;
 my $ini = new Configfile::Ini('test.ini');

=head1 DESCRIPTION

 Have you ever wanted an easy to use interface to your own
 config files, but ended up doing 'require  mysettings.pl'
 because you couldn't be bothered?  Configfile::Ini solves
 that  for  you, giving you an object in  exchange for the
 name of your settings file.
 
 For compatibility with other config file formats, Ini can
 understand  hierarchical ini files using double colons as
 delimiters.  Just make sure you don't create name clashes
 by assigning both a value and a subentry to the same name
 in the file. This is currently supported for one sublevel
 only, which will have to be improved in future releases.

=head1 EXAMPLES

 We assume the content of the file 'test.ini' to be:
 [myentry]
 ;comment
 thisssetting = that
 thatsetting=this
 ;end of ini
 
 
 use Configfile::Ini;
 my $settingsfile = 'test.ini';
 my $settings = new Configfile::Ini($Settingsfile);
 
 # Get all settings
 my %allsettings = $settings->get_all_settings;
 
 # Get a subsection (called an entry here, but it's 
 # whatever's beneath a [section] header)
 my %entry = $settings->get_entry('myentry');
 
 # Get a specific setting from an entry
 my $value = $settings->get_entry_setting('myentry',
                                          'thissetting');

 # Get a specific setting from an entry, giving a default
 # to fall back on
 my value = $settings->get_entry_setting('myentry',
                                         'missingsetting',
                                         'defaultvalue');
 We can also make use of subentries, with a ini file like
 this:

 [book]
 title=A book of chapters
 author=Me, Myself and Irene

 [book::chapter1]
 title=The First Chapter, ever
 file=book/chapter1.txt

 [book::chapter2]
 title=The Next Chapter, after the First Chapter, ever
 file=book/chapter2.txt
 # btw, you can use unix style comments, too...
 ;end of ini

 use Configfile::Ini;
 my $settingsfile = 'test2.ini';
 my $ini = new Configfile::Ini($Settingsfile);
 
 my %book = $ini->get_entry('book');
 my %chap1 = $ini->get_entry_setting('book','chapter1');
 my $chap1title = $chapter1{'title'};
 
 # Want to see the inifile?
 # If you can live without comments and blank lines ;),
 # try this:
 print("My inifile looks like this:\n$ini\nCool, huh?\n");

=head1 METHODS

=item get_all_settings

Returns a hash of all settings found in the processed file

=item get_entry ENTRYNAME

Returns a hash of the settings within the entry ENTRYNAME

=item get_entry_setting ENTRYNAME,SETTINGNAME [,DEFAULTVALUE]

Returns the value corresponding to ENTRYNAME,SETTINGSNAME. If the value isn't set it returns undef or, optionally, the DEFAULTVALUE

=item set_all_settings SETTINGSHASH

Fill settings with data from SETTINGSHASH

=item set_entry ENTRYNAME,ENTRYHASH

Fill the entry ENTRYNAME with data from ENTRYHASH

=item set_entry_setting ENTRYNAME,SETTINGNAME,VALUE

Set the setting ENTRYNAME,SETTINGSNAME to VALUE

=head2 UTILITY METHODS

=item expand_tilde STRINGTOEXPAND

Does normal tilde expansion if the environment variable $HOME is set

=head1 COPYRIGHT

Copyright 2001 Eddie Olsson.

 This library is free software; you can redistribute it
 and/or modify it under the same terms as Perl itself.


=head1 AUTHOR

Eddie Olsson <ewt@avajadi.org>

=head1 SEE ALSO

L<perl>.

=cut
