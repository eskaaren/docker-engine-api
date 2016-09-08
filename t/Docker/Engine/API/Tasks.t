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

$s->remove(
  {
    id => 'taskstestservice'
  }
);

my $res = $s->create(
  {
    Name         => 'taskstestservice',
    TaskTemplate => {
      ContainerSpec => {
        Image => 'nginx:alpine',
      }
    }
  }
);

my $t = $d->{tasks};

$res = $t->list(
  {
    filters => {
      name => 'taskstestservice'
    }
  }
);
like($res->{content}, qr/CreatedAt/, "List tasks");
my $id = decode_json($res->{content})->[0]->{ID};

$res = $t->inspect(
  {
    id => $id
  }
);
like($res->{content}, qr/CreatedAt/, "Inspect task");

done_testing();

END {
  $s->remove(
    {
      id => 'taskstestservice'
    }
  );
  $swarm->leave();
}
