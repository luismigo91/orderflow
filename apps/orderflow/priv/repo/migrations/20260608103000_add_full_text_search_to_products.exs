defmodule Orderflow.Repo.Migrations.AddFullTextSearchToProducts do
  use Ecto.Migration

  def up do
    execute("""
    ALTER TABLE products
    ADD COLUMN search_vector tsvector
    GENERATED ALWAYS AS (
      setweight(to_tsvector('spanish', coalesce(name, '')), 'A') ||
      setweight(to_tsvector('spanish', coalesce(description, '')), 'B')
    ) STORED
    """)

    execute("CREATE INDEX products_search_idx ON products USING GIN(search_vector)")
  end

  def down do
    execute("DROP INDEX IF EXISTS products_search_idx")
    execute("ALTER TABLE products DROP COLUMN IF EXISTS search_vector")
  end
end
