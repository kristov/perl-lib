package ACME::Geo::3D::Line;

use strict;
use warnings;

use constant POINTA => 0;
use constant POINTB => 1;
use constant FORMULAXZ => 2;
use constant FORMULAYZ => 3;

sub new {
    my ( $class, $pointa, $pointb ) = @_;
    my $self = [ $pointa, $pointb ];
    bless( $self, $class );
    return $self;
}

sub point_a { return $_[0]->[POINTA] }
sub point_b { return $_[0]->[POINTB] }

sub x_value_at_z {
    my ( $self, $z ) = @_;
    my $formula = $self->xz_formula;
    return value_at_z( $formula, $z );
}

sub y_value_at_z {
    my ( $self, $z ) = @_;
    my $formula = $self->yz_formula;
    return value_at_z( $formula, $z );
}

sub x_formula_applies_for_z {
    my ( $self, $z ) = @_;
    my $formula = $self->xz_formula;
    return formula_applies_for_z( $formula, $z );
}

sub y_formula_applies_for_z {
    my ( $self, $z ) = @_;
    my $formula = $self->yz_formula;
    return formula_applies_for_z( $formula, $z );
}

sub value_at_z {
    my ( $formula, $z ) = @_;
    return $formula->[1] if !defined $formula->[0];
    return $z if !$formula->[0];
    return ( $z - $formula->[1] ) / $formula->[0];
}

sub formula_applies_for_z {
    my ( $formula, $z ) = @_;
    my $zbound = $formula->[3];
    return 1 if ( $z >= $zbound->[0] && $z <= $zbound->[1] );
    return 0;
}

sub xz_formula {
    my ( $self ) = @_;
    if ( !defined $self->[FORMULAXZ] ) {
        $self->[FORMULAXZ] = _genenerate_formula(
            $self->[POINTA]->X,
            $self->[POINTB]->X,
            $self->[POINTA]->Z,
            $self->[POINTB]->Z,
        );
    }
    return $self->[FORMULAXZ];
}

sub yz_formula {
    my ( $self ) = @_;
    if ( !defined $self->[FORMULAYZ] ) {
        $self->[FORMULAYZ] = _genenerate_formula(
            $self->[POINTA]->Y,
            $self->[POINTB]->Y,
            $self->[POINTA]->Z,
            $self->[POINTB]->Z,
        );
    }
    return $self->[FORMULAYZ];
}

sub _genenerate_formula {
    my ( $x1, $x2, $y1, $y2 ) = @_;

    my $xd = $x2 - $x1;
    my $yd = $y2 - $y1;

    my $s = ( $xd == 0 ) ? undef : $yd / $xd;

    my $o = ( $xd == 0 ) ? $x1 : ( $y2 - ( $s * $x2 ) );

    my ( $xl, $xu ) = ( $x1 > $x2 ) ? ( $x2, $x1 ) : ( $x1, $x2 );
    my ( $yl, $yu ) = ( $y1 > $y2 ) ? ( $y2, $y1 ) : ( $y1, $y2 );

    return [ $s, $o, [ $xl, $xu ], [ $yl, $yu ] ];
}

sub equal {
    my ( $self, $l ) = @_;
    return (
        $self->point_a->equal( $l->point_a ) &&
        $self->point_b->equal( $l->point_b )
    ) ? 1 : 0;
}

1;
