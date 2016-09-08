package Docker::Engine::API::Networks;
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
        endpoint => '/networks',
        params   => {
          filters => $self->{http}->undef_stripper_to_json(
            {
              driver => defined($opts->{filters}->{driver}) ? ["$opts->{filters}->{driver}"] : undef,
              id     => defined($opts->{filters}->{id})     ? ["$opts->{filters}->{id}"]     : undef,
              label  => defined($opts->{filters}->{label})  ? ["$opts->{filters}->{label}"]  : undef,
              name   => defined($opts->{filters}->{name})   ? ["$opts->{filters}->{name}"]   : undef,
              type   => defined($opts->{filters}->{type})   ? ["$opts->{filters}->{type}"]   : undef
            }
          ) // undef
        }
      }
    )
  );
}

sub inspect {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/networks/$opts->{id}"
      }
    )
  );
}

sub create {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => '/networks/create'
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          Name           => $opts->{Name}           // undef,
          CheckDuplicate => $opts->{CheckDuplicate} // undef,
          Driver         => $opts->{Driver}         // undef,
          EnableIPv6     => $opts->{EnableIPv6}     // undef,
          IPAM           => $opts->{IPAM}           // undef,
          Internal       => $opts->{Internal}       // undef,
          Options        => $opts->{Options}        // undef,
          Labels         => $opts->{Labels}         // undef
        }
      ) // undef
    }
  );
}

sub connect {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/networks/$opts->{id}/connect"
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          Container      => $opts->{Container}      // undef,
          EndpointConfig => $opts->{EndpointConfig} // undef
        }
      ) // undef
    }
  );
}

sub disconnect {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/networks/$opts->{id}/disconnect"
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          Container => $opts->{Container} // undef,
          Force     => $opts->{Force}     // undef
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
        endpoint => "/networks/$opts->{id}"
      }
    )
  );
}

1;
