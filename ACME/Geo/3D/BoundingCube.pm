package ACME::Geo::3D::BoundingCube;

use strict;
use warnings;

use constant MINX   => 0;
use constant MAXX   => 1;
use constant MINY   => 2;
use constant MAXY   => 3;
use constant MINZ   => 4;
use constant MAXZ   => 5;

sub new {
    my ( $class, $minx, $maxx, $miny, $maxy, $minz, $maxz ) = @_;
    my $self = [ $minx, $maxx, $miny, $maxy, $minz, $maxz ];
    bless( $self, $class );
    return $self;
}

sub minx { return $_[0]->[MINX] }
sub maxx { return $_[0]->[MAXX] }
sub miny { return $_[0]->[MINY] }
sub maxy { return $_[0]->[MAXY] }
sub minz { return $_[0]->[MINZ] }
sub maxz { return $_[0]->[MAXZ] }

sub new_from_3gon {
    my ( $class, $three_gon ) = @_;

    my $minx;
    my $maxx;
    my $miny;
    my $maxy;
    my $minz;
    my $maxz;

    my $p1 = $three_gon->line_a->point_a;
    $minx = $p1->X if ( !defined $minx || $p1->X < $minx );
    $maxx = $p1->X if ( !defined $maxx || $p1->X > $maxx );
    $miny = $p1->Y if ( !defined $miny || $p1->Y < $miny );
    $maxy = $p1->Y if ( !defined $maxy || $p1->Y > $maxy );
    $minz = $p1->Z if ( !defined $minz || $p1->Z < $minz );
    $maxz = $p1->Z if ( !defined $maxz || $p1->Z > $maxz );

    my $p2 = $three_gon->line_b->point_a;
    $minx = $p2->X if ( !defined $minx || $p2->X < $minx );
    $maxx = $p2->X if ( !defined $maxx || $p2->X > $maxx );
    $miny = $p2->Y if ( !defined $miny || $p2->Y < $miny );
    $maxy = $p2->Y if ( !defined $maxy || $p2->Y > $maxy );
    $minz = $p2->Z if ( !defined $minz || $p2->Z < $minz );
    $maxz = $p2->Z if ( !defined $maxz || $p2->Z > $maxz );

    my $p3 = $three_gon->line_c->point_a;
    $minx = $p3->X if ( !defined $minx || $p3->X < $minx );
    $maxx = $p3->X if ( !defined $maxx || $p3->X > $maxx );
    $miny = $p3->Y if ( !defined $miny || $p3->Y < $miny );
    $maxy = $p3->Y if ( !defined $maxy || $p3->Y > $maxy );
    $minz = $p3->Z if ( !defined $minz || $p3->Z < $minz );
    $maxz = $p3->Z if ( !defined $maxz || $p3->Z > $maxz );

    return $class->new( $minx, $maxx, $miny, $maxy, $minz, $maxz );
}

sub new_from_3gons {
    my ( $class, @three_gons ) = @_;

    my $work_bbox;

    for my $three_gon ( @three_gons ) {
        my $bbox = $three_gon->bounding_cube;
        $work_bbox = $bbox->union( $work_bbox );
    }

    return $work_bbox;
}

sub union {
    my ( $self, $bbox ) = @_;
    return $self if !defined $bbox;

    my $minx;
    my $maxx;
    my $miny;
    my $maxy;
    my $minz;
    my $maxz;

    $minx = ( $self->[MINX] < $bbox->[MINX] ) ? $self->[MINX] : $bbox->[MINX];
    $maxx = ( $self->[MAXX] > $bbox->[MAXX] ) ? $self->[MAXX] : $bbox->[MAXX];
    $miny = ( $self->[MINY] < $bbox->[MINY] ) ? $self->[MINY] : $bbox->[MINY];
    $maxy = ( $self->[MAXY] > $bbox->[MAXY] ) ? $self->[MAXY] : $bbox->[MAXY];
    $minz = ( $self->[MINZ] < $bbox->[MINZ] ) ? $self->[MINZ] : $bbox->[MINZ];
    $maxz = ( $self->[MAXZ] > $bbox->[MAXZ] ) ? $self->[MAXZ] : $bbox->[MAXZ];

    return __PACKAGE__->new( $minx, $maxx, $miny, $maxy, $minz, $maxz );
}

1;
