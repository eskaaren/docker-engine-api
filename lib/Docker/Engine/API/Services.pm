package Docker::Engine::API::Services;
use v5.24;
use lib '../../../../lib';
use Docker::Engine::API::HTTP;
use strict;
use warnings;

sub new {
  my ($class, $self) = @_;
  $self->{http} = Docker::Engine::API::HTTP->new($self->{base_url});
  return bless $self, $class;
}

sub list {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/services",
        params   => {
          filters => $self->{http}->undef_stripper_to_json(
            {
              id   => defined($opts->{filters}->{id})   ? ["$opts->{filters}->{id}"]   : undef,
              name => defined($opts->{filters}->{name}) ? ["$opts->{filters}->{name}"] : undef
            }
          ) // undef
        }
      }
    )
  );
}

sub create {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/services/create"
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          Name         => $opts->{Name}         // undef,
          Labels       => $opts->{Labels}       // undef,
          TaskTemplate => $opts->{TaskTemplate} // undef,
          Mode         => $opts->{Mode}         // undef,
          UpdateConfig => $opts->{UpdateConfig} // undef,
          Networks     => $opts->{Networks}     // undef,
          EndpointSpec => $opts->{EndpointSpec}     // undef
        }
      ) // undef
    }
  );
}

sub remove {
  my ($self, $opts) = @_;

  return $self->{http}->delete(
    $self->{http}->url_builder(
      {
        endpoint => "/services/$opts->{id}"
      }
    )
  );
}

sub inspect {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/services/$opts->{id}"
      }
    )
  );
}

sub update {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/services/$opts->{id}/update",
        params   => {
          version => $opts->{version}
        }
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          Name         => $opts->{Name}         // undef,
          Labels       => $opts->{Labels}       // undef,
          TaskTemplate => $opts->{TaskTemplate} // undef,
          Mode         => $opts->{Mode}         // undef,
          UpdateConfig => $opts->{UpdateConfig} // undef,
          Networks     => $opts->{Networks}     // undef,
          Endpoint     => $opts->{Endpoint}     // undef
        }
      ) // undef
    }
  );
}

1;
