# Global Island Database Tool

A tool to allow users to validate and improve the accuracy of islands
across the world.

## Setup

You'll need to create a `config/cartodb_config.yml` file:

    host: '<your cartodb host>'
    oauth_key: 'oauthkey'
    oauth_secret: 'oauthsecret'
    username: 'username'
    password: 'password'

Also, you'll need to create a `config/http_auth_config.yml`:

    development:
      admins:
        -
          login: 'login'
          password: 'password'

Next, populate your database with the islands from CartoDB:

    rake import_islands_from_cartodb

There are quite a few islands (~450 000 Apr 2014), so in development you
can probably run that task for a few minutes, then CTRL-C out of it and
use the few hundred islands it retrieved.

## Development

### Testing

Run the tests with `bundle exec guard`.

## Redis & Resque

If you want to run the download background tasks, you need redis-server
installed and running. Default redis config is in `config/resque.yml`.

To get the workers running:

    rake resque:start_workers

You can view the status of resque jobs in the browser using the resque-web tool.

## Deployment

Brightbox has a 32-bit architecture, and thus non-ruby gems have to be
compiled as x86-linux, rather than x86_64. Currently this only affects
`libv8`.

When deploying, ensure that `/vendor/cache` contains an x86-linux
version of `libv8`. This can be downloaded here:
http://rubygems.org/downloads/libv8-3.11.8.13-x86-linux.gem

## CartoDB SQL

SQL to create the initial database on CartoDB:

    -- Import data
    INSERT INTO gid_development_copy (the_geom, status, polygon_id, name, name_local, iso_3) (SELECT the_geom, 'original' AS status, id AS polygon_id, name, name_local, iso_3 FROM gid_import_1_100000);
    INSERT INTO gid_development_copy (the_geom, status, polygon_id, name, name_local, iso_3) (SELECT the_geom, 'original' AS status, id AS polygon_id, name, name_local, iso_3 FROM gid_import_100001_200000);
    INSERT INTO gid_development_copy (the_geom, status, polygon_id, name, name_local, iso_3) (SELECT the_geom, 'original' AS status, id AS polygon_id, name, name_local, iso_3 FROM gid_import_200001_300000);
    INSERT INTO gid_development_copy (the_geom, status, polygon_id, name, name_local, iso_3) (SELECT the_geom, 'original' AS status, id AS polygon_id, name, name_local, iso_3 FROM gid_import_300001_464020);

    -- Create indexes for the next queries
    CREATE INDEX name_idx ON films (name);
    CREATE INDEX iso_3_idx ON films (iso_3);

    -- Update island_ids (name_local was not used because there were some NULL values - and the value seemed redundant with name)
    UPDATE gid_development_copy SET island_id = g.group_id FROM (SELECT MIN(cartodb_id) AS group_id, min(name) AS gname, min(iso_3) as giso_3 FROM gid_development_copy AS b GROUP BY name, iso_3) AS g WHERE name IS NOT NULL AND name = g.gname AND iso_3 = g.giso_3 AND cartodb_id < 500000 AND cartodb_id >= 0

    -- Update island_ids (for rows with empty ISO_3 codes)
    UPDATE gid_development_copy SET island_id = (SELECT MIN(cartodb_id) FROM gid_development_copy AS b WHERE gid_development_copy.name=b.name GROUP BY name) WHERE iso_3 IS NULL;

    -- Update island_ids (for rows with empty names)
    UPDATE gid_development_copy SET island_id = cartodb_id WHERE name IS NULL;
