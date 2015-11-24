# Global Island Database Tool

A tool to allow users to validate and improve the accuracy of islands
across the world.

## Installation

Global Island Database is a pretty standard Rails application, backed by a Postgres database, and using the `dotenv` gem for storing secrets. To run Global Island Database, proceed with the usual commands:
```
$ git clone https://github.com/unepwcmc/global-island-database.git global-island-database
$ cd global-island-database
$ bundle install
```

### dotenv

Ocean Data Viewer uses the `dotenv` gem to manage environment variables. Before
starting the server, create a copy of the file `.env.example` and edit the
needed variables.

*Note:* this applies to all environments, so make sure to have a `.env` file in your capistrano `linked_files` when deploying.

### DB population

Next, create, migrate, and populate your database with the islands from CartoDB:
```
$ bundle exec rake db:setup
$ bundle exec rake import_islands_from_cartodb
```

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

    $ bundle exec rake resque:start_workers

You can view the status of resque jobs in the browser using the resque-web tool.

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
