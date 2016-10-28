package ACME::Geo::3D::Point;

use strict;
use warnings;

use constant XI => 0;
use constant YI => 1;
use constant ZI => 2;

sub new {
    my ( $class, $x, $y, $z ) = @_;
    my $self = [ $x, $y, $z ];
    bless( $self, $class );
    return $self;
}

sub X { return $_[0]->[XI] }
sub Y { return $_[0]->[YI] }
sub Z { return $_[0]->[ZI] }

sub equal {
    my ( $self, $p ) = @_;
    return (
        $self->X == $p->X &&
        $self->Y == $p->Y &&
        $self->Z == $p->Z
    ) ? 1 : 0;
}

1;
