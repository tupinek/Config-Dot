package Config::Dot;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use Config::Utils qw(hash);
use English qw(-no_match_vars);
use Error::Pure qw(err);
use Readonly;

# Constants.
Readonly::Scalar my $EMPTY_STR => q{};

# Version.
our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;
	my $self = bless {}, $class;

	# Config hash.
	$self->{'config'} = {};

	# Set conflicts detection as error.
	$self->{'set_conflicts'} = 1;

	# File suffix.
	$self->{'suffix'} = $EMPTY_STR;

	# Process params.
	set_params($self, @params);

	# Check config hash.
	if (ref $self->{'config'} ne 'HASH') {
		err 'Config parameter must be a reference to hash.';
	}

	# Count of lines.
	$self->{'count'} = 0;

	# Stack.
	$self->{'stack'} = [];

	# Object.
	return $self;
}

# Parse text or array of texts.
sub parse {
	my ($self, $tmp) = @_;
	my @text;
	if (ref $tmp eq 'ARRAY') {
		@text = @{$tmp};
	} else {
		@text = split m/$INPUT_RECORD_SEPARATOR/sm, $tmp;
	}
	foreach my $line (@text) {
		$self->{'count'}++;
		$self->_parse($line);
	}
	return $self->{'config'};
}

# Reset content.
sub reset {
	my $self = shift;
	$self->{'config'} = {};
	return;
}

# Parse string.
sub _parse {
	my ($self, $string) = @_;

	# Remove comments on single line.
	$string =~ s/^\s*#.*$//sm;

	# Blank space.
	if ($string =~ m/^\s*$/sm) {
		return 0;
	}

	# Split.
	my ($key, $val) = split m/=/sm, $string, 2;

	# Not a key.
	if (length $key < 1) {
		return 0;
	}

	# Bad key.
	if ($key !~ m/^[-\w\.:,]+\+?$/sm) {
		err "Bad key '$key' in string '$string' at line ".
			"'$self->{'count'}'.";
	}

	my @tmp = split m/\./sm, $key;
	hash($self, \@tmp, $val);

	# Ok.
	return 1;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Config::Dot - Module for simple configure file parsing.

=head1 SYNOPSIS

 my $cnf = Config->new(%params);
 my $struct_hr = $cnf->parse($string);
 $cnf->reset;

=head1 METHODS

=over 8

=item B<new(%params)>

 Constructor.

=over 8

=item * B<config>

 Reference to hash structure with default config data.
 Default value is reference to blank hash.

=item * B<set_conflicts>

 TODO
 Default value is 1.

=item * B<suffix>

 TODO
 Default suffix is ''.

=back

=item B<parse($tmp)>

Parse string $tmp or reference to array $tmp and returns hash structure.

=item B<reset()>

Reset content in class (config parameter).

=back

=head1 PARAMETER_FILE

 # Comment.
 # blabla

 # White space.
 /^\s*$/

 # Parameters.
 # Key must be '[-\w\.:,]+'.
 # Default mode with '=' separator ('sep' parameter in constructor.).
 key=val
 key2.subkey.subkey=val

=head1 ERRORS

 Mine:
         TODO

 From Config::Utils::conflict():
         TODO

 From Class::Utils::set_params():
         Unknown parameter '%s'.

=head1 EXAMPLE

 # cat file 'file.conf':
 # par1=val1
 # par2=val2
 # par3.subpar=val3

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Config::Dor;

 # Object.
 my $struct_hr = Config::Dot->new->parse_file('file.conf');

 # hash structure in $struct_hr:
 # {
 #   'par1' => 'val1',
 #   'par2' => 'val2',
 #   'par3' => {
 #     'subpar' => 'val3',
 #   }
 # }

=head1 DEPENDENCIES

L<Class::Utils>,
L<Config::Utils>,
L<Englisg>,
L<Error::Pure>.

=head1 SEE ALSO

L<Cnf>,
L<Cnf::More>,

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

BSD license.

=head1 VERSION

0.01

=cut
