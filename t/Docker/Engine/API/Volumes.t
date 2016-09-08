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

my $v = $d->{volumes};

my $res = $v->create(
  {
    Name => 'testvolume'
  }
);
is($res->{status}, 201, 'Create volume');

$res = $v->list(
  {
    filters => {
      name     => ['testvolume'],
      dangling => ['true']
    }
  }
);
like($res->{content}, qr/Volumes\"/, "List volumes");

$res = $v->inspect(
  {
    name => 'testvolume'
  }
);
like($res->{content}, qr/Name\":\"testvolume/, 'Inspect volume');

$res = $v->remove(
  {
    name => 'testvolume'
  }
);
is($res->{status}, 204, 'Delete volume');

done_testing();
