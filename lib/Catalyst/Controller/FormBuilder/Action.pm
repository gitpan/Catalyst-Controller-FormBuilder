package Catalyst::Controller::FormBuilder::Action;

use strict;
use CGI::FormBuilder;
use File::Spec;
use NEXT;

use base qw/Catalyst::Action Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/_attr_params/);

sub _setup_form {
    my ( $self, $controller, $c ) = @_;

    # Load configured defaults from the user, and add in some
    # custom settings needed to meld FormBuilder with Catalyst
    my $config = $controller->config->{'Controller::FormBuilder'} || {};

    my %attr = (
        debug   => $c->debug ? 2 : 0,
        %{ $config->{new} || {} },
        params  => $c->req,
        action  => $c->req->uri->path,
        header  => 0,                    # always disable headers
        cookies => 0,                    # and cookies
        title   => __PACKAGE__,
        c       => $c,                   # allow \&validate to get $c
    );

    if (my $source = $self->_source($controller, $c) ) {
        $attr{source} = $source;
    }

    s/^\.*/./;    # XX workaround for CGI::FormBuilder::Source::File bug
    return CGI::FormBuilder->new( \%attr );
}

sub _source {
    my ( $self, $controller, $c ) = @_;

    my $config = $controller->config->{'Controller::FormBuilder'} || {};
    my $name  = $self->_attr_params->[0] || $self->reverse;

    # remove leading and trailing slashes
    $name =~ s#^/+##;
    $name =~ s#/+$##;

    my $fbdir = $self->_form_path($controller, $c);

    # Attempt to autoload config and template files
    # Cleanup suffix to allow ".fb" or "fb" in config

    my $fbsuf = exists( $config->{form_suffix} ) ? $config->{form_suffix} : 'fb';
    $fbsuf =~ s/^\.*/./ if $fbsuf;
    my $fbfile = "$name$fbsuf";

    $c->log->debug("Form ($name): Looking for config file $fbfile")
      if $c->debug;

    # Look for files relative to our current action url (/books/edit)
    for my $dir ( @$fbdir ) {
        my $conf = File::Spec->catfile( $dir, $fbfile );
        if ( -f $conf && -r _ ) {
            $c->log->debug("Form ($name): Found form config $conf")
              if $c->debug;
            return $conf;
        }
    }

    my $err = sprintf( "Form (%s): Can't find form config $fbfile in: %s",
        $name, join( ", ", @$fbdir ) );

    if ( $self->_attr_params->[0] ) {
        $c->log->error($err);
        $c->error($err);
    }
    else {
        $c->log->debug($err) if $c->debug;
    }

    return;
}

sub _form_path {
    my ( $self, $controller, $c ) = @_;

    my $config = $controller->config->{'Controller::FormBuilder'} || {};
    my $fbdir = [ File::Spec->catfile( $c->config->{home}, 'root', 'forms' ) ];

    if ( my $dir = $config->{form_path} ) {
        $fbdir = ref $dir ? $dir : [ split /\s*:\s*/, $dir ];
    }

    return $fbdir;
}

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;

    return $self->NEXT::execute(@_)
      unless exists $self->attributes->{ActionClass}
      && $self->attributes->{ActionClass}[0] eq
      $controller->_fb_setup->{action};

    my $form = $self->_setup_form(@_);
    $controller->_formbuilder($form);
    $self->NEXT::execute(@_);

    $self->setup_template_vars( @_ );
}

1;
