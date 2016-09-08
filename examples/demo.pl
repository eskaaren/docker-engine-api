#!/usr/bin/env perl
use v5.24;
use lib '../lib';
use Docker::Engine::API;
use JSON::PP;
use Env;
no warnings 'experimental::smartmatch';

{
  my ($module, $cmd) = @ARGV;

  my $api = Docker::Engine::API->new(
    {
      base_url => 'http://127.0.0.1:3375'
    }
  );

  for ($module) {
    swarm($api, $cmd) when /swarm/;
    containers($api, $cmd) when /containers/;
    services($api, $cmd) when /services/;

    default { say "Incorrect arguments: $module $cmd" }
  }
}

sub swarm {
  my ($api, $cmd) = @_;

  for ($cmd) {

    when (/init/) {
      to_stdout(
        $api->{swarm}->init(
          {
            ListenAddr      => '127.0.0.1',
            ForceNewCluster => JSON::PP->true()
          }
        )
      );
    }

    when (/join/) {
      to_stdout(
        $api->{swarm}->join(
          {
            ListenAddr  => '0.0.0.0',
            RemoteAddrs => ['127.0.0.1']
          }
        )
      );
    }

    when (/leave/) {
      to_stdout($api->{swarm}->leave())
    }

    default { say "Incorrect argument: $cmd" }
  }
}

sub containers {
  my ($api, $cmd) = @_;

  for ($cmd) {

    when (/list/) {
      to_stdout($api->{containers}->list())
    }

    when (/create/) {
      to_stdout(
        $api->{containers}->create(
          {
            name   => 'democontainer',
            config => {
              Image => "nginx:latest"
            }
          }
        )
      );
    }

    when (/start/) {
      to_stdout(
        $api->{containers}->start(
          {
            id => 'democontainer'
          }
        )
      );
    }

    when (/remove/) {
      to_stdout(
        $api->{containers}->remove(
          {
            id    => 'democontainer',
            v     => 1,
            force => 1
          }
        )
      );
    }

    when (/top/) {
      to_stdout(
        $api->{containers}->top(
          {
            id      => 'democontainer',
            ps_args => 'aux'
          }
        )
      );
    }

    default { say "Incorrect argument: $cmd" }
  }
}

sub services {
  my ($api, $cmd) = @_;

  for ($cmd) {

    when (/create/) {
      to_stdout(
        $api->{services}->create(
          {
            Name   => 'demoservice',
            Labels => {
              type => 'demo'
            },
            TaskTemplate => {
              ContainerSpec => {
                Image => 'nginx:alpine'
              }
            },
            Mode => {
              Replicated => {
                Replicas => 3
              }
            },
            EndpointSpec => {
              Ports => [
                {
                  Protocol      => "tcp",
                  PublishedPort => 8080,
                  TargetPort    => 80
                }
              ]
            }
          }
        )
      );
    }

    when (/remove/) {
      to_stdout(
        $api->{services}->remove(
          {
            id => 'demoservice'
          }
        )
      );
    }

    when (/inspect/) {
      to_stdout(
        $api->{services}->inspect(
          {
            id => 'demoservice'
          }
        )
      );
    }

    when (/list/) {
      to_stdout($api->{services}->list());
    }

    when (/update/) {
      to_stdout(
        $api->{services}->update(
          {
            id   => 'f0ul0dr2z68lsxobgflr1ic1n',
            version => 23,
            TaskTemplate => {
              ContainerSpec => {
                Image => 'nginx:alpine'
              }
            },
            Mode => {
              Replicated => {
                Replicas => 2
              }
            }
          }
        )
      );
    }

    default { say "Incorrect argument: $cmd" }
  }
}

sub to_stdout {
  my $res = shift;
  say $res->{status};
  say $res->{content};
}
