package ACME::Geo::Util::Converter;

use JSON qw();
use ACME::Geo::Point;
use ACME::Geo::Line;
use ACME::Geo::Layer;

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
    return $self->json->encode( $self->_serialise_layer( $layer ) );
}

sub _serialise_layer {
    my ( $self, $layer ) = @_;

    my $slayer = [];
    for my $path ( @{ $layer } ) {
        my $spath = [];
        for my $line ( @{ $path } ) {
            my $start   = $line->start;
            my $end     = $line->end;
            my $normal  = $line->normal;
            my $sline = [
                [ $start->X, $start->Y ],
                [ $end->X, $end->Y ],
            ];
            push @{ $sline }, [ $normal->X, $normal->Y ] if $normal;

            push @{ $spath }, $sline;
        }
        push @{ $slayer }, $spath;
    }

    return $slayer;
}

sub layerjson_to_geolayer {
    my ( $self, $json ) = @_;
    return $self->_deserialise_layer( $self->json->decode( $json ) );
}

sub _deserialise_layer {
    my ( $self, $slayer ) = @_;

    my @paths;
    for my $spath ( @{ $slayer } ) {
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
        push @paths, $path;
    }
    my $layer = ACME::Geo::Layer->new( @paths );
    return $layer;
}

1;
