desc 'Import islands from CartoDB'
task :import_islands_from_cartodb, [:page] => :environment do |t, args|
  def reset_island_id_sequence
    Island.connection.execute "SELECT SETVAL('islands_id_seq', (SELECT MAX(id) FROM islands) + 1);"
  end

  trap("SIGINT") do
    puts "Resetting Island id_seq"
    reset_island_id_sequence
    exit
  end

  page = args['page'].to_i || 0
  per_page = 200

  begin
    puts "### Importing islands offset #{page*per_page}"

    result = CartoDB::Connection.query """
      SELECT id_gid AS id,
        MIN(name) AS name,
        MIN(name_local) AS name_local,
        MIN(iso3) AS iso_3,
        MIN(country) AS country
      FROM gid_production
      GROUP BY id_gid
      ORDER BY id_gid
      OFFSET #{page*per_page} LIMIT #{per_page}"

    result.rows.each do |row|
      island = Island.find_or_initialize_by_id(row.id)

      puts "Creating island '#{row.name}' in #{row.country} (#{row.id})"

      island.update_attribute('name', row.name)
      island.update_attribute('name_local', row.name_local)
      island.update_attribute('iso_3', row.iso_3)
      island.update_attribute('country', row.country)
    end

    page = page + 1
  end while result.rows.length == per_page
end
