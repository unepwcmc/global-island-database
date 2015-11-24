class Island < ActiveRecord::Base
  validates :name, presence: true
  validates :source, presence: true

  def self.filter(params)
    result = self.scoped

    # If the query is a number, search for the ID instead
    # This could be done with query.to_i.to_a?(Numeric) which seems more robust
    # but this would result in things like "3a" -> "3" which is not ideal.
    if (params[:query] =~ /^[0-9]+$/).nil?
      result = result.where("name ILIKE ? OR iso_3 ILIKE ?", params[:query], params[:query])
    else
      result = result.where(id: params[:query].to_i)
    end

    result
  end

  after_update :update_cartodb
  def update_cartodb
    sql = <<-SQL
          UPDATE #{APP_CONFIG['cartodb_table']}
          SET
            name       = '#{self.name}',
            name_local = '#{self.name_local}',
            country    = '#{self.country}'
          WHERE id_gid = #{self.id};
          SQL
    CartoDb.query sql
  rescue CartoDb::ClientError
    errors.add :base, 'There was an error trying to update the island.'
    logger.info "There was an error trying to execute the following query:\n#{sql}"
  end

  before_destroy :delete_from_cartodb
  def delete_from_cartodb
    sql = <<-SQL
          DELETE FROM #{APP_CONFIG['cartodb_table']}
          WHERE island_id = '#{self.id}'
          SQL
    CartoDb.query sql
  rescue CartoDb::ClientError
    errors.add :base, 'There was an error trying to render the map.'
    logger.info "There was an error trying to execute the following query:\n#{sql}"
  end
end
