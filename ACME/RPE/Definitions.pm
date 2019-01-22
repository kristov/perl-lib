package ACME::RPE::Definitions;

use strict;
use warnings;
use ACME::RPE::Definitions::SpecificImpulse;
use ACME::RPE::Definitions::Thrust;

sub specific_impulse {
    return ACME::RPE::Definitions::SpecificImpulse::specific_impulse(@_);
}

sub thrust {
    return ACME::RPE::Definitions::Thrust::thrust(@_);
}

1;
