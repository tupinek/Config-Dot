use strict;
use warnings;

use Test::More 'tests' => 3;
use Test::NoWarnings;

BEGIN {

	# Test.
	use_ok('Config::Dot');
}

# Test.
require_ok('Config::Dot');
