#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Data::Dumper;

use_ok( 'ACME::Geo::3D::3Gon' );

constructors();
simple();
half_way_up();
no_intersection();
at_the_tip();
vertical_triangle_base();
flat_triangle();
vertical_weird_triangle();
bounding_cube();

done_testing();

sub simple {
    diag( 'line_zplane_intersection(): simple' );
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 2, 2, 1 ],
        [ 1, 3, 0 ],
        [ 1, 1, 0 ],
    );
    my $i1 = $g1->line_zplane_intersection( 0 );
    my $i1p1 = $i1->start;
    my $i1p2 = $i1->end;
    is_deeply( [ $i1p1->X + 0, $i1p1->Y + 0 ], [ 1, 3 ], 'start point correct' );
    is_deeply( [ $i1p2->X + 0, $i1p2->Y + 0 ], [ 1, 1 ], 'end point correct' );
}

sub half_way_up {
    diag( 'line_zplane_intersection(): half_way_up' );
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 2, 2, 1 ],
        [ 1, 3, 0 ],
        [ 1, 1, 0 ],
    );
    my $i1 = $g1->line_zplane_intersection( 0.5 );
    my $i1p1 = $i1->start;
    my $i1p2 = $i1->end;
    is_deeply( [ $i1p1->X + 0, $i1p1->Y + 0 ], [ 1.5, 2.5 ], 'start point correct' );
    is_deeply( [ $i1p2->X + 0, $i1p2->Y + 0 ], [ 1.5, 1.5 ], 'end point correct' );
}

sub no_intersection {
    diag( 'line_zplane_intersection(): no_intersection' );
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 2, 2, 1 ],
        [ 1, 3, 0 ],
        [ 1, 1, 0 ],
    );
    my $i1 = $g1->line_zplane_intersection( 2 );
    is( $i1, undef, 'correctly undefined' );
}

sub at_the_tip {
    diag( 'line_zplane_intersection(): at_the_tip' );
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 2, 2, 1 ],
        [ 1, 3, 0 ],
        [ 1, 1, 0 ],
    );
    my $i1 = $g1->line_zplane_intersection( 1 );
    is( $i1, undef, 'correctly undefined' );
}

sub vertical_triangle_base {
    diag( 'line_zplane_intersection(): vertical_triangle_base' );
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 1, 2, 1 ],
        [ 1, 3, 0 ],
        [ 1, 1, 0 ],
    );
    my $i1 = $g1->line_zplane_intersection( 0 );
    my $i1p1 = $i1->start;
    my $i1p2 = $i1->end;
    is_deeply( [ $i1p1->X + 0, $i1p1->Y + 0 ], [ 1, 3 ], 'start point correct' );
    is_deeply( [ $i1p2->X + 0, $i1p2->Y + 0 ], [ 1, 1 ], 'end point correct' );
}

sub flat_triangle {
    diag( 'line_zplane_intersection(): flat_triangle' );
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 2, 2, 0 ],
        [ 1, 3, 0 ],
        [ 1, 1, 0 ],
    );
    my $i1 = $g1->line_zplane_intersection( 0 );
    is( $i1, undef, 'correctly undefined' );
}

sub vertical_weird_triangle {
    diag( 'line_zplane_intersection(): vertical_weird_triangle' );
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 0, 0, 0 ],
        [ 0, 0, 10 ],
        [ 0, 10, 0 ],
    );
    my $i1 = $g1->line_zplane_intersection( 4 );
    my $i1p1 = $i1->start;
    my $i1p2 = $i1->end;
    is_deeply( [ $i1p1->X + 0, $i1p1->Y + 0 ], [ 0, 0 ], 'start point correct' );
    is_deeply( [ $i1p2->X + 0, $i1p2->Y + 0 ], [ 0, 6 ], 'end point correct' );
}

sub constructors {
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 2, 2, 1 ],
        [ 1, 3, 0 ],
        [ 1, 1, 0 ],
    );
    is( ref( $g1 ), 'ACME::Geo::3D::3Gon', 'new_from_points_raw_refs(): constructed' );
    my $g2 = ACME::Geo::3D::3Gon->new_from_points(
        ACME::Geo::3D::Point->new( 2, 2, 1 ),
        ACME::Geo::3D::Point->new( 1, 3, 0 ),
        ACME::Geo::3D::Point->new( 1, 1, 0 ),
    );
    is( ref( $g2 ), 'ACME::Geo::3D::3Gon', 'new_from_points(): constructed' );

    my $g3 = ACME::Geo::3D::3Gon->new(
        ACME::Geo::3D::Line->new(
            ACME::Geo::3D::Point->new( 2, 2, 1 ),
            ACME::Geo::3D::Point->new( 1, 3, 0 ),
        ),
        ACME::Geo::3D::Line->new(
            ACME::Geo::3D::Point->new( 1, 3, 0 ),
            ACME::Geo::3D::Point->new( 1, 1, 0 ),
        ),
        ACME::Geo::3D::Line->new(
            ACME::Geo::3D::Point->new( 1, 1, 0 ),
            ACME::Geo::3D::Point->new( 2, 2, 1 ),
        ),
    );
    is( ref( $g3 ), 'ACME::Geo::3D::3Gon', 'new(): constructed' );

    is( $g1->equal( $g2 ), 1, 'g1 equal g2' );
    is( $g2->equal( $g3 ), 1, 'g2 equal g3' );
}

sub bounding_cube {
    my $g1 = ACME::Geo::3D::3Gon->new_from_points_raw_refs(
        [ 2, 2, 1 ],
        [ 1, 3, 0 ],
        [ 1, 1, 0 ],
    );
    my $bc = $g1->bounding_cube;
    is( $bc->[0], 1, 'minx good' );
    is( $bc->[1], 2, 'maxx good' );
    is( $bc->[2], 1, 'miny good' );
    is( $bc->[3], 3, 'maxy good' );
    is( $bc->[4], 0, 'minz good' );
    is( $bc->[5], 1, 'maxz good' );
}
