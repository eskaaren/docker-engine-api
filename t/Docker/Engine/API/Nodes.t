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

my $s = $d->{swarm};

my $res = $s->init(
  {
    ListenAddr      => '127.0.0.1',
    ForceNewCluster => JSON::PP->false()
  }
);

my $n = $d->{nodes};

$res = $n->list(
  {
    filters => {
      role => 'manager'
    }
  }
);
like($res->{content}, qr/CreatedAt/, "List nodes");

my $id = decode_json($res->{content})->[0]->{ID};
$res = $n->inspect(
  {
    id => $id
  }
);
like($res->{content}, qr/CreatedAt/, "Inspect node");

END {
  $s->leave();
}

done_testing();
