package GtkZ::App::Graphical::Cairo;

use Moose;
use GtkZ::App::Graphical;
use Glib qw( TRUE FALSE );
extends 'GtkZ::App::Graphical';

has 'layer_renderers' => (
    is => 'rw',
    isa => 'ArrayRef',
    builder => '_build_layer_renderers',
);

sub _build_layer_renderers {
    my ( $self ) = @_;
    return [
        sub {
            my ( $self, $cr ) = @_;
            $cr->save;
            $cr->rectangle( 50, 55, 100, 100 );
            $cr->set_line_width( 1 );
            $cr->set_source_rgb( 1, 0, 0 );
            $cr->stroke();
            $cr->restore;
        },
    ];
}

has 'surface' => (
    is  => 'rw',
    isa => 'Cairo::ImageSurface',
    documentation => "Cairo surface we are drawing to",
);

has 'zoom_state' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub {
        return {
            view_off    => [ 0, 0 ],
            zoom_point  => [ 0, 0 ],
            offset      => [ 0, 0 ],
            scale       => 1,
            prev_scale  => undef,
        };
    },
    documentation => 'State of zooming',
);


sub render {
    my ( $self, $widget, $event ) = @_;

    my ( $da_width, $da_height ) = $self->da->window->get_size;

    $self->da_width( $da_width );
    $self->da_height( $da_height );

    $self->do_cairo_drawing;
    my $cr = Gtk2::Gdk::Cairo::Context->create( $widget->window );
    $cr->set_source_surface( $self->surface(), 0, 0 );
    $cr->paint;
    return FALSE;
}

sub create_surface {
    my ( $self ) = @_;
    my $surface = Cairo::ImageSurface->create( 'argb32', $self->da_width, $self->da_height );
    $self->surface( $surface );
}

sub do_cairo_drawing {
    my ( $self ) = @_;

    $self->create_surface();

    my $surface = $self->surface();
    my $cr = Cairo::Context->create( $surface );

    my $layer_renderers = $self->layer_renderers;

    for my $renderer ( @{ $layer_renderers } ) {
        $renderer->( $self, $cr );
    }
}

sub zoom_in {
    my ( $self, $event ) = @_;
    return $self->zoom( 1, $event );
}

sub zoom_out {
    my ( $self, $event ) = @_;
    return $self->zoom( -1, $event );
}

sub zoom {
    my ( $self, $scale_mod, $event ) = @_;

    my $state = $self->zoom_state;

    $state->{zoom_point}->[0] = $event->x;
    $state->{zoom_point}->[1] = $event->y;

    my $scale = $state->{scale};
    $state->{scale} += $scale_mod;
    if ( $state->{scale} < 1 ) {
        $state->{scale} = $scale;
        return;
    }
    $state->{prev_scale} = $scale;

    #my $scale_change = $state->{scale} - $state->{prev_scale};
    my $scale_change = 1;

    my $diff = [];
    for my $I ( 0, 1 ) {
        my $diff = $state->{zoom_point}->[$I] - $state->{view_off}->[$I];
        my $diff_in_model_scale = $diff / $scale;
        $state->{view_off}->[$I] = ( $scale_mod > 0 )
            ? $state->{view_off}->[$I] - $diff_in_model_scale
            : $state->{view_off}->[$I] + $diff_in_model_scale;
    }

    return $self->invalidate_da;
}

sub translate {
    my ( $self, $point ) = @_;

    my $state = $self->zoom_state;
    my $trans_point = [];

    for my $I ( 0, 1 ) {
        $trans_point->[$I] = ( $point->[$I] * $state->{scale} ) + $state->{view_off}->[$I];
    }

    return $trans_point;
}

sub _debug {
    my ( $template, @args ) = @_;
    my $message = @args ? sprintf( $template, @args ) : $template;
    warn "$message\n";
}

sub button_clicked {
    my ( $self, $da, $event ) = @_;
    my $state = $self->zoom_state;
    $state->{button_on} = 1;
    $state->{mouse_pos} = [ $event->x, $event->y ];
}

sub button_released {
    my ( $self, $da, $event ) = @_;
    my $state = $self->zoom_state;
    if ( $state->{button_on} ) {
        $state->{button_on} = 0;
        my $mouse = [ $event->x, $event->y ];
        my $diff = [];
        for my $I ( 0, 1 ) {
            $diff->[$I] = $mouse->[$I] - $state->{mouse_pos}->[$I];
            $state->{view_off_new}->[$I] -= $diff->[$I];
        }
        $self->invalidate_da;
    }
    return TRUE;
}

sub motion_notify {
    my ( $self, $da, $event ) = @_;
    my $state = $self->zoom_state;
    if ( $state->{button_on} ) {
        my $mouse = [ $event->x, $event->y ];
        for my $I ( 0, 1 ) {
            
        }
    }
}

sub scroll {
    my ( $self, $da, $event ) = @_;

    my $direction = $event->direction;
    if ( $direction eq 'up' ) {
        return $self->zoom_in( $event );
    }
    else {
        return $self->zoom_out( $event );
    }
}

__PACKAGE__->meta->make_immutable;
