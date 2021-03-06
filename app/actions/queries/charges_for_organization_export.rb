module Queries
  class ChargesForOrganizationExport < Export
    attr_accessor :organization

    def klass
      Charge
    end

    def sql
      <<-ENDOFQUERY
      WITH charges_customers AS (
        SELECT charges.id AS charge_id,
               customers.id AS customer_id,
               string_agg(tags.name, ',') AS tags
        FROM charges
        JOIN customers ON customers.id = charges.customer_id
        LEFT JOIN charges_tags ON charges_tags.charge_id = charges.id
        LEFT JOIN tags ON tags.id = charges_tags.tag_id
        WHERE charges.organization_id = #{ActiveRecord::Base.sanitize(organization.id)}
        GROUP BY charges.id, customers.id
        )
      SELECT customers.first_name, customers.last_name, customers.email, charges.amount, charges.currency, charges.config, charges.status, charges.created_at, charges_customers.tags
      FROM charges_customers
      JOIN charges ON charges.id = charges_customers.charge_id
      JOIN customers ON customers.id = charges_customers.customer_id
      ENDOFQUERY
    end

    def name
      "charges-#{organization.slug}"
    end
  end
end
