package HTTP::Tool::TemplateBootstrap3;

use Moose;
use XML::Parser;

has base_dir => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    documentation => 'Where to find files when using render',
);

has hook_Start => (
    is => 'ro',
    isa => 'CodeRef',
    documentation => 'Hook to run on start tags',
);

has hook_End => (
    is => 'ro',
    isa => 'CodeRef',
    documentation => 'Hook to run on end tags',
);

has hook_Char => (
    is => 'ro',
    isa => 'CodeRef',
    documentation => 'Hook to run for inter-tag character text',
);

has hook_Default => (
    is => 'ro',
    isa => 'CodeRef',
    documentation => 'Hook to run on all content',
);

my %TYPES = (
    'container'         => [ 'div', 'container' ],
    'container-fluid'   => [ 'div', 'container-fluid' ],
    'row'               => [ 'div', 'row' ],
    'col-md'            => [ 'div', 'col-md' ],
    'col-md-offset'     => [ 'div', 'col-md-offset' ],
    'col-xs'            => [ 'div', 'col-xs' ],
    
    'lead'              => [ 'p', 'lead' ],
    'text-left'         => [ 'p', 'text-left' ], 
    'text-center'       => [ 'p', 'text-center' ],
    'text-right'        => [ 'p', 'text-right' ],
    'text-justify'      => [ 'p', 'text-justify' ],
    'text-nowrap'       => [ 'p', 'text-nowrap' ],

    'text-muted'        => [ 'p', 'text-muted' ],
    'text-primary'      => [ 'p', 'text-primary' ],
    'text-success'      => [ 'p', 'text-success' ],
    'text-info'         => [ 'p', 'text-info' ],
    'text-warning'      => [ 'p', 'text-warning' ],
    'text-danger'       => [ 'p', 'text-danger' ],

    'list-inline'       => [ 'ul', 'list-inline' ],

    'table'             => [ 'table', 'table' ],
    'table-striped'     => [ 'table', 'table table-striped' ],
    'table-bordered'    => [ 'table', 'table table-bordered' ],
    'table-hover'       => [ 'table', 'table table-hover' ],
    'table-condensed'   => [ 'table', 'table table-condensed' ],
    'tr-active'         => [ 'tr', 'active' ],
    'tr-success'        => [ 'tr', 'success' ],
    'tr-warning'        => [ 'tr', 'warning' ],
    'tr-danger'         => [ 'tr', 'danger' ],
    'tr-info'           => [ 'tr', 'info' ],
    'td-active'         => [ 'td', 'active' ],
    'td-success'        => [ 'td', 'success' ],
    'td-warning'        => [ 'td', 'warning' ],
    'td-danger'         => [ 'td', 'danger' ],
    'td-info'           => [ 'td', 'info' ],

    'form-group'        => [ 'div', 'form-group' ],
    'input-group'       => [ 'div', 'input-group' ],
    'form-inline'       => [ 'form', 'form-inline' ],
    'form-horizontal'   => [ 'form', 'form-horizontal' ],

    'input'             => [ 'input', 'form-control' ],
    'select'            => [ 'select', 'form-control' ],

    'a-button'          => [ 'a', 'btn-primary' ],
    'a-success'         => [ 'a', 'btn-success' ],
    'a-info'            => [ 'a', 'btn-info' ],
    'a-warning'         => [ 'a', 'btn-warning' ],
    'a-success'         => [ 'a', 'btn-success' ],

    'a-btn'             => [ 'a', 'btn-primary' ],
    'a-btn-success'     => [ 'a', 'btn-success' ],
    'a-btn-info'        => [ 'a', 'btn-info' ],
    'a-btn-warning'     => [ 'a', 'btn-warning' ],
    'a-btn-success'     => [ 'a', 'btn-success' ],

    'btn'               => [ 'button', 'btn-default' ],
    'btn-primary'       => [ 'button', 'btn-primary' ],
    'btn-success'       => [ 'button', 'btn-success' ],
    'btn-info'          => [ 'button', 'btn-info' ],
    'btn-warning'       => [ 'button', 'btn-warning' ],
    'btn-group'         => [ 'div', 'btn-group' ],

    'img-rounded'       => [ 'img', 'img-rounded' ],
    'img-circle'        => [ 'img', 'img-circle' ],
    'img-thumbnail'     => [ 'img', 'img-thumbnail' ],
    'img-responsive'    => [ 'img', 'img-responsive' ],

    'progress'          => [ 'div', 'progress' ],
    'progress-striped'  => [ 'div', 'progress progress-striped' ],
    'progress-bar'      => [ 'div', 'progress-bar' ],
    'progress-bar-success'  => [ 'div', 'progress-bar progress-bar-success' ],
    'progress-bar-info'     => [ 'div', 'progress-bar progress-bar-info' ],
    'progress-bar-warning'  => [ 'div', 'progress-bar progress-bar-warning' ],
    'progress-bar-danger'   => [ 'div', 'progress-bar progress-bar-danger' ],

    'dropdown'          => [ 'div', 'dropdown' ],
    'dropdown-menu'     => [ 'ul', 'dropdown-menu' ],
    'dropdown-toggle'   => [ 'button', 'dropdown-toggle' ],

    'nav-tabs'          => [ 'ul', 'nav nav-tabs' ],
    'nav-pills'         => [ 'ul', 'nav nav-pills' ],
    'nav-pills-stacked' => [ 'ul', 'nav nav-pills nav-stacked' ],
    'navbar-nav'        => [ 'ul', 'nav navbar-nav' ],

    'li-dropdown'       => [ 'li', 'dropdown' ],
    'divider'           => [ 'li', 'divider' ],

    'navbar-default'    => [ 'nav', 'navbar navbar-default' ],
    'navbar-fixed-top'  => [ 'nav', 'navbar navbar-default navbar-fixed-top' ],
    'navbar-fixed-bottom'   => [ 'nav', 'navbar navbar-default navbar-fixed-bottom' ],
    'navbar-static-top' => [ 'nav', 'navbar navbar-default navbar-static-top' ],

    'breadcrumb'        => [ 'ol', 'breadcrumb' ],

    'label-default'     => [ 'span', 'label label-default' ],
    'label-primary'     => [ 'span', 'label label-primary' ],
    'label-success'     => [ 'span', 'label label-success' ],
    'label-info'        => [ 'span', 'label label-info' ],
    'label-warning'     => [ 'span', 'label label-warning' ],
    'label-danger'      => [ 'span', 'label label-danger' ],

    'alert-danger'      => [ 'div', 'alert alert-danger' ],

    'jumbotron'         => [ 'div', 'jumbotron' ],

    'well'              => [ 'div', 'well' ],
    'well-lg'           => [ 'div', 'well-lg' ],
    'well-sm'           => [ 'div', 'well-sm' ],
);

sub render {
    my ( $self, $template ) = @_;
}

sub transform {
    my ( $self, $xml ) = @_;

    my $html = "";

    my $p = XML::Parser->new(
        Handlers => {
            Start   => sub { $html .= $self->Start( @_ ) },
            End     => sub { $html .= $self->End( @_ ) },
            Char    => sub { $html .= $self->Char( @_ ) },
            Default => sub { $html .= $self->Default( @_ ) },
        },
    );

    eval {
        $p->parse( $xml );
        1;
    }
    or do {
        die "error parsing xml: $@\n$xml";
    };

    return $html;
}

sub build_tag {
    my ( $self, $class, $tag, %attr ) = @_;
    
    my $attr_str = _attr_str( $class, %attr );

    return $attr_str ? "<$tag $attr_str>" : "<$tag>";
}

sub Start {
    my ( $self, $p, $el, %attr ) = @_;
    
    my ( $tag, $class ) = _resolver( $el );

    my $new = $self->build_tag( $class, $tag, %attr );
    
    if ( $self->hook_Start ) {
        $new = $self->hook_Start->( $self, $el, $tag, $class, $new, %attr );
    }

    return $new;
}

sub End {
    my ( $self, $p, $el, %attr ) = @_;

    my ( $tag, $class ) = _resolver( $el );

    my $new = "</$tag>";

    if ( $self->hook_End ) {
        $new = $self->hook_End->( $self, $el, $tag, $class, $new, %attr );
    }

    return $new;
}

sub Char {
    my ( $self, $p, $el, %attr ) = @_;

    my $new = $el;

    if ( $self->hook_Char ) {
        $new = $self->hook_Char->( $self, $el, undef, undef, $new, %attr );
    }

    return $new;
}

sub Default {
    my ( $self, $p, $el, %attr ) = @_;

    my $new = $el;

    if ( $self->hook_Default ) {
        $new = $self->hook_Default->( $self, $el, undef, undef, $new, %attr );
    }

    return $el;
}

sub _attr_str {
    my ( $class, %attr ) = @_;
    if ( $class ) {
        if ( $attr{class} ) {
            $attr{class} = $class . " " . $attr{class};
        }
        else {
            $attr{class} = $class;
        }
    }
    return join( ' ', map { $_ . '="' . $attr{$_} . '"' } keys %attr );
}

sub _resolver {
    my ( $el ) = @_;
    if ( $el =~ /(.+)-([0-9]+)$/ ) {
        my ( $tag, $num ) = ( $1, $2 );
        if ( $TYPES{$tag} ) {
            my ( $tmp_tag, $tmp_class ) = @{ $TYPES{$tag} };
            return ( $tmp_tag, "$tmp_class-$num" );
        }
        else {
            return ( $el, undef );
        }
    }
    elsif ( $TYPES{$el} ) {
        return @{ $TYPES{$el} };
    }
    else {
        return ( $el, undef );
    }
}

1;
