package Docker::Engine::API::Swarm;
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

sub inspect {
  my ($self, $opts) = @_;

  return $self->{http}->get(
    $self->{http}->url_builder(
      {
        endpoint => "/swarm"
      }
    )
  );
}

sub init {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/swarm/init"
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          ListenAddr      => $opts->{ListenAddr}      // undef,
          AdvertiseAddr   => $opts->{AdvertiseAddr}   // undef,
          ForceNewCluster => $opts->{ForceNewCluster} // undef,
          Spec            => $opts->{Spec}            // undef
        }
      ) // undef
    }
  );
}

sub join {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/swarm/join"
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          ListenAddr    => $opts->{ListenAddr}    // undef,
          AdvertiseAddr => $opts->{AdvertiseAddr} // undef,
          RemoteAddrs   => $opts->{RemoteAddrs}   // undef,
          JoinToken     => $opts->{JoinToken}     // undef
        }
      ) // undef
    }
  );
}

sub leave {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/swarm/leave",
        params   => {
          force => 1
        }
      }
    )
  );
}

sub update {
  my ($self, $opts) = @_;

  return $self->{http}->post(
    $self->{http}->url_builder(
      {
        endpoint => "/swarm/update",
        params   => {
          version            => $opts->{version}            // undef,
          rotateWorkerToken  => $opts->{rotateWorkerToken}  // undef,
          rotateManagerToken => $opts->{rotateManagerToken} // undef
        }
      }
    ),
    {
      headers => {'Content-Type' => 'application/json'},
      content => $self->{http}->undef_stripper_to_json(
        {
          Name          => $opts->{Name}          // undef,
          Orchestration => $opts->{Orchestration} // undef,
          Raft          => $opts->{Raft}          // undef,
          Dispatcher    => $opts->{Dispatcher}    // undef,
          CAConfig      => $opts->{CAConfig}      // undef,
          JoinTokens    => $opts->{JoinTokens}    // undef
        }
      )
    }
  );
}

1;
