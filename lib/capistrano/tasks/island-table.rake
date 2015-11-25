namespace :populate do
  desc "populate island table"
  task :generate do
    on roles(:app) do
      within release_path do
      execute :bundle, :exec, :rake, "RAILS_ENV=#{fetch(:rails_env)} 'import_islands_from_cartodb'"
    end
  end
end
end

