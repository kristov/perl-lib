package ACME::Geo::3D::3Gon;

use strict;
use warnings;
use ACME::Geo::3D::Line;
use ACME::Geo::3D::Point;
use ACME::Geo::3D::BoundingCube;
use ACME::Geo::Point;
use ACME::Geo::Line;

use constant LINEA  => 0;
use constant LINEB  => 1;
use constant LINEC  => 2;
use constant NORMAL => 3;
use constant BCUBE  => 4;

sub line_a { return $_[0]->[LINEA] }
sub line_b { return $_[0]->[LINEB] }
sub line_c { return $_[0]->[LINEC] }
sub normal { return $_[0]->[NORMAL] }

sub new {
    my ( $class, $linea, $lineb, $linec ) = @_;
    my $self = [ $linea, $lineb, $linec ];
    bless( $self, $class );
    return $self;
}

sub new_from_points {
    my ( $class, $pointa, $pointb, $pointc ) = @_;
    my $linea = ACME::Geo::3D::Line->new( $pointa, $pointb );
    my $lineb = ACME::Geo::3D::Line->new( $pointb, $pointc );
    my $linec = ACME::Geo::3D::Line->new( $pointc, $pointa );
    return $class->new( $linea, $lineb, $linec );
}

sub new_from_points_raw_refs {
    my ( $class, $ca, $cb, $cc ) = @_;
    my $pointa = ACME::Geo::3D::Point->new( @{ $ca } );
    my $pointb = ACME::Geo::3D::Point->new( @{ $cb } );
    my $pointc = ACME::Geo::3D::Point->new( @{ $cc } );
    return $class->new_from_points( $pointa, $pointb, $pointc );
}

sub new_from_points_raw_refs_with_normal {
    my ( $class, $normal, $ca, $cb, $cc ) = @_;
    my $self = $class->new_from_points_raw_refs( $ca, $cb, $cc );
    $self->[NORMAL] = ACME::Geo::3D::Point->new( @{ $normal } );
    return $self;
}

sub line_zplane_intersection {
    my ( $self, $z ) = @_;

    my @lines = ( $self->[LINEA], $self->[LINEB], $self->[LINEC] );

    my $points_on_z_plane = [];
    for my $line ( @lines ) {
        my $point_a = $line->point_a;
        push @{ $points_on_z_plane }, $point_a if $point_a->Z == $z;
    }

    my $nr_points_on_z_plane = scalar( @{ $points_on_z_plane } );

    # point of the facet is on the plane
    return if $nr_points_on_z_plane == 1;

    # facet is flat on this plane
    return if $nr_points_on_z_plane == 3;

    if ( $nr_points_on_z_plane == 2 ) {
        # edge of the facet is on the plane, flatten into 2D
        my $p0 = $points_on_z_plane->[0];
        my $p1 = $points_on_z_plane->[1];
        my $p0f = ACME::Geo::Point->new( $p0->X, $p0->Y );
        my $p1f = ACME::Geo::Point->new( $p1->X, $p1->Y );
        my $normal;
        if ( $self->[NORMAL] ) {
            $normal = ACME::Geo::Point->new( $self->[NORMAL]->X, $self->[NORMAL]->Y );
        }
        return ACME::Geo::Line->new( $p0f, $p1f, $normal );
    }

    my $applicable_lines = [];
    for my $line ( @lines ) {
        if ( $line->x_formula_applies_for_z( $z ) ) {
            push @{ $applicable_lines }, $line;
        }
    }

    return if !scalar( @{ $applicable_lines } );

    my $points = [];
    for my $line ( @{ $applicable_lines } ) {
        my $x = $line->x_value_at_z( $z );
        my $y = $line->y_value_at_z( $z );
        my $point = ACME::Geo::Point->new( $x, $y );
        push @{ $points }, $point;
    }

    if ( scalar( @{ $points } ) == 2 ) {
        # line connecting the two intersects
        my $normal;
        if ( $self->[NORMAL] ) {
            $normal = ACME::Geo::Point->new( $self->[NORMAL]->X, $self->[NORMAL]->Y );
        }
        return ACME::Geo::Line->new( $points->[0], $points->[1], $normal );
    }

    die "not possible";
}

sub equal {
    my ( $self, $g ) = @_;
    return (
        $self->[LINEA]->equal( $g->[LINEA] ) &&
        $self->[LINEB]->equal( $g->[LINEB] ) &&
        $self->[LINEC]->equal( $g->[LINEC] )
    ) ? 1 : 0;
}

sub bounding_cube {
    my ( $self ) = @_;
    if ( !defined $self->[BCUBE] ) {
        $self->[BCUBE] = ACME::Geo::3D::BoundingCube->new_from_3gon( $self );
    }
    return $self->[BCUBE];
}

1;
