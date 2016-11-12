package ACME::Geo::BoundingBox;

use strict;
use warnings;

use constant MINX   => 0;
use constant MAXX   => 1;
use constant MINY   => 2;
use constant MAXY   => 3;

sub new {
    my ( $class, $minx, $maxx, $miny, $maxy ) = @_;
    my $self = [
        sprintf( '%0.4f', $minx ),
        sprintf( '%0.4f', $maxx ),
        sprintf( '%0.4f', $miny ),
        sprintf( '%0.4f', $maxy ),
    ];
    bless( $self, $class );
    return $self;
}

sub minx { return $_[0]->[MINX] }
sub maxx { return $_[0]->[MAXX] }
sub miny { return $_[0]->[MINY] }
sub maxy { return $_[0]->[MAXY] }

sub width { return $_[0]->[MAXX] - $_[0]->[MINX] }
sub height { return $_[0]->[MAXY] - $_[0]->[MINY] }

sub new_from_line {
    my ( $class, $line ) = @_;

    my $minx;
    my $maxx;
    my $miny;
    my $maxy;

    my $p1 = $line->start;
    $minx = $p1->X if ( !defined $minx || $p1->X < $minx );
    $maxx = $p1->X if ( !defined $maxx || $p1->X > $maxx );
    $miny = $p1->Y if ( !defined $miny || $p1->Y < $miny );
    $maxy = $p1->Y if ( !defined $maxy || $p1->Y > $maxy );

    my $p2 = $line->end;
    $minx = $p2->X if ( !defined $minx || $p2->X < $minx );
    $maxx = $p2->X if ( !defined $maxx || $p2->X > $maxx );
    $miny = $p2->Y if ( !defined $miny || $p2->Y < $miny );
    $maxy = $p2->Y if ( !defined $maxy || $p2->Y > $maxy );

    return $class->new( $minx, $maxx, $miny, $maxy );
}

sub new_from_lines {
    my ( $class, @lines ) = @_;

    my $work_bbox;

    for my $line ( @lines ) {
        my $bbox = $line->bounding_box;
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

    $minx = ( $self->[MINX] < $bbox->[MINX] ) ? $self->[MINX] : $bbox->[MINX];
    $maxx = ( $self->[MAXX] > $bbox->[MAXX] ) ? $self->[MAXX] : $bbox->[MAXX];
    $miny = ( $self->[MINY] < $bbox->[MINY] ) ? $self->[MINY] : $bbox->[MINY];
    $maxy = ( $self->[MAXY] > $bbox->[MAXY] ) ? $self->[MAXY] : $bbox->[MAXY];

    return __PACKAGE__->new( $minx, $maxx, $miny, $maxy );
}

1;
