class AddFunctionCriterionMatchesShip < ActiveRecord::Migration
  def self.up

    execute <<-SQL

      create function criterion_matches_ship(c criteria, s ships) returns boolean as $$ begin
        return
             (c.type = 'built_year equal' and s.built_year = c.integer_a)
          or (c.type = 'dwt between' and s.dwt between c.integer_a and c.integer_b);

      end $$
      language plpgsql;

    SQL

  end

  def self.down
    execute <<-SQL

      drop function criterion_matches_ship(criteria, ships);

    SQL
  end
end
