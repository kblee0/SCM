package SCM::Config;

use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

$VERSION = '3.05';

@ISA = qw/ Exporter /;
@EXPORT = qw(get_src_to_objs_list);
push @EXPORT;

sub get_src_to_objs_list {
	my %rule;

	$rule{'c'   } = 'o';
	$rule{'sc'  } = 'o';
	$rule{'cpp' } = 'o';
	$rule{'pc'  } = 'o';
	$rule{'lpp' } = 'o';
	$rule{'ypp' } = 'o';
	$rule{'l'   } = 'o';
	$rule{'y'   } = 'o';
	$rule{'java'} = 'class';

	return %rule;
}

