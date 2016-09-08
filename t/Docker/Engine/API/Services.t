use v5.24;
use Test::More;
use lib '../../../../lib';
use lib 'lib';
use Docker::Engine::API;
use JSON::PP;
use Env;

unless (-d '/tmp/swarmtest') {
  mkdir '/tmp/swarmtest';
}

my $d = Docker::Engine::API->new(
  {
    base_url => $ENV{'prove_url'} // 'http://127.0.0.1:3375'
  }
);

my $swarm = $d->{swarm};
$swarm->init(
  {
    ListenAddr      => '127.0.0.1',
    ForceNewCluster => JSON::PP->false()
  }
);

my $s = $d->{services};

my $res = $s->create(
  {
    Name   => 'testservice',
    Labels => {
      testlabel => 'testlabelval'
    },
    TaskTemplate => {
      ContainerSpec => {
        Image => 'nginx:alpine',

      }
    },
    Mode => {
      Replicated => {
        Replicas => 3
      }
    }
  }
);
like($res->{content}, qr/ID":/, 'Create service');

my $id = decode_json($res->{content})->{ID};
$res = $s->list(
  {
    filters => {
      id => $id
    }
  }
);
like($res->{content}, qr/testlabelval/, "List service");

$res = $s->inspect(
  {
    id => $id
  }
);
like($res->{content}, qr/testlabelval/, "Inspect service");

my $version = decode_json($res->{content})->{Version}->{Index};
$res = $s->update(
  {
    id           => $id,
    version      => $version,
    TaskTemplate => {
      ContainerSpec => {
        Image => 'nginx:alpine'
      }
    },
    Labels => {
      testlabel => 'updatedtestlabelval'
    }
  }
);
is($res->{status}, 200, "Update service");

$res = $s->inspect(
  {
    id => $id
  }
);
like($res->{content}, qr/updatedtestlabelval/, "Verify update service");

$res = $s->remove(
  {
    id => $id
  }
);
is($res->{status}, 200, "Remove service");

done_testing();

END {
  $swarm->leave();
}
