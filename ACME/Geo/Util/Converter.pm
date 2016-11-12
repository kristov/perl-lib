package ACME::Geo::Util::Converter;

use JSON qw();
use ACME::Geo::Point;
use ACME::Geo::Line;
use ACME::Geo::Layer;
use Math::Geometry::Planar;

use constant JSONO => 0;

sub new {
    my ( $class, $pretty ) = @_;
    $pretty = 0 if !defined $pretty;
    my $self = [ JSON->new->pretty( $pretty ) ];
    return bless( $self, $class );
}

sub json {
    my ( $self ) = @_;
    return $self->[JSONO];
}

sub geolayer_to_layerjson {
    my ( $self, $layer ) = @_;
    return $self->json->encode( $self->serialise_layer( $layer ) );
}

sub geopath_to_pathjson {
    my ( $self, $path ) = @_;
    return $self->json->encode( $self->serialise_path( $path ) );
}

sub geopoint_to_pointjson {
    my ( $self, $point ) = @_;
    return $self->json->encode( $self->serialise_point( $point ) );
}

sub serialise_layer {
    my ( $self, $layer ) = @_;

    my $slayer = [];
    for my $path ( @{ $layer } ) {
        my $spath = $self->serialise_path( $path );
        push @{ $slayer }, $spath;
    }

    return $slayer;
}

sub serialise_path {
    my ( $self, $path ) = @_;

    my $spath = [];
    for my $line ( @{ $path } ) {
        my $start   = $line->start;
        my $end     = $line->end;
        my $normal  = $line->normal;
        my $sline = [
            $self->serialise_point( $start ),
            $self->serialise_point( $end ),
        ];
        push @{ $sline }, $self->serialise_point( $normal ) if $normal;

        push @{ $spath }, $sline;
    }

    return $spath;
}

sub serialise_point {
    my ( $self, $point ) = @_;
    return [ $point->X + 0, $point->Y + 0 ];
}

sub layerjson_to_geolayer {
    my ( $self, $json ) = @_;
    return $self->deserialise_layer( $self->json->decode( $json ) );
}

sub pathjson_to_geopath {
    my ( $self, $json ) = @_;
    return $self->deserialise_path( $self->json->decode( $json ) );
}

sub deserialise_layer {
    my ( $self, $slayer ) = @_;

    my @paths;
    for my $spath ( @{ $slayer } ) {
        my $path = $self->deserialise_path( $spath );
        push @paths, $path;
    }
    my $layer = ACME::Geo::Layer->new( @paths );
    return $layer;
}

sub deserialise_path {
    my ( $self, $spath ) = @_;

    my @lines;
    for my $sline ( @{ $spath } ) {
        my ( $sstart, $send, $snormal ) = @{ $sline };
        my $start = ACME::Geo::Point->new( @{ $sstart } );
        my $end = ACME::Geo::Point->new( @{ $send } );
        my $normal = ACME::Geo::Point->new( @{ $snormal } ) if $snormal;
        my $line = ACME::Geo::Line->new( $start, $end, $normal ? $normal : () );
        push @lines, $line;
    }
    my $path = ACME::Geo::Path->new( @lines );

    return $path;
}

sub deserialise_point {
    my ( $self, $spoint ) = @_;
    return ACME::Geo::Point->new( @{ $spoint } );
}

sub geopath_to_mathgeometryplanar {
    my ( $self, $path ) = @_;

    my $polygon = Math::Geometry::Planar->new;
    my $points = [];
    for my $line ( @{ $path } ) {
        my $start = $line->start;
        push @{ $points }, [ $start->X, $start->Y ];
    }
    $polygon->points( $points );

    my $gpc = $polygon->convert2gpc;
    return $gpc;
}

1;
