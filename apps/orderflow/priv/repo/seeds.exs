alias Orderflow.Repo
alias Orderflow.Accounts
alias Orderflow.Catalog

# Users - only create if not exists

IO.puts("Creating users...")

users = [
  %{
    email: "admin@orderflow.com",
    password: "admin123",
    name: "Administrador",
    role: :admin,
    phone: "555-0001"
  },
  %{
    email: "chef@orderflow.com",
    password: "chef123",
    name: "Chef Principal",
    role: :chef,
    phone: "555-0002"
  },
  %{
    email: "rider@orderflow.com",
    password: "rider123",
    name: "Repartidor",
    role: :rider,
    phone: "555-0003"
  },
  %{
    email: "customer@orderflow.com",
    password: "customer123",
    name: "Cliente Ejemplo",
    role: :customer,
    phone: "555-0004"
  }
]

Enum.each(users, fn user_attrs ->
  case Accounts.get_user_by_email(user_attrs.email) do
    nil ->
      case Accounts.register_user(user_attrs) do
        {:ok, user} -> IO.puts("  Created user: #{user.name} (#{user.role})")
        {:error, changeset} -> IO.puts("  Error creating user: #{inspect(changeset.errors)}")
      end

    user ->
      IO.puts("  User already exists: #{user.name} (#{user.role})")
  end
end)

# Categories - only create if not exists

IO.puts("Creating categories...")

categories = [
  %{name: "Bebidas", description: "Refrescos, jugos, café y té", sort_order: 1},
  %{name: "Entradas", description: "Aperitivos, sopas y ensaladas", sort_order: 2},
  %{name: "Platos Principales", description: "Hamburguesas, pizzas, pastas y más", sort_order: 3},
  %{name: "Postres", description: "Helados, pasteles y dulces", sort_order: 4}
]

Enum.each(categories, fn category_attrs ->
  existing = Catalog.list_categories() |> Enum.find(fn c -> c.name == category_attrs.name end)

  if is_nil(existing) do
    case Catalog.create_category(category_attrs) do
      {:ok, category} -> IO.puts("  Created category: #{category.name}")
      {:error, changeset} -> IO.puts("  Error creating category: #{inspect(changeset.errors)}")
    end
  else
    IO.puts("  Category already exists: #{existing.name}")
  end
end)

# Products - only create if not exists

IO.puts("Creating products...")

bebidas = Catalog.list_categories() |> Enum.find(fn c -> c.name == "Bebidas" end)
entradas = Catalog.list_categories() |> Enum.find(fn c -> c.name == "Entradas" end)
platos = Catalog.list_categories() |> Enum.find(fn c -> c.name == "Platos Principales" end)
postres = Catalog.list_categories() |> Enum.find(fn c -> c.name == "Postres" end)

products = [
  # Bebidas
  %{
    name: "Coca-Cola 500ml",
    description: "Refresco de cola",
    price: 3.00,
    stock: 50,
    active: true,
    category_id: bebidas.id
  },
  %{
    name: "Agua Mineral",
    description: "Agua mineral natural 500ml",
    price: 2.00,
    stock: 40,
    active: true,
    category_id: bebidas.id
  },
  %{
    name: "Jugo de Naranja",
    description: "Jugo natural de naranja",
    price: 4.50,
    stock: 20,
    active: true,
    category_id: bebidas.id
  },
  # Entradas
  %{
    name: "Nachos con Queso",
    description: "Nachos crujientes con salsa de queso",
    price: 6.00,
    stock: 30,
    active: true,
    category_id: entradas.id
  },
  %{
    name: "Alitas de Pollo",
    description: "Alitas picantes (6 piezas)",
    price: 8.50,
    stock: 25,
    active: true,
    category_id: entradas.id
  },
  %{
    name: "Ensalada César",
    description: "Lechuga, crutones, parmesano y aderezo césar",
    price: 7.00,
    stock: 15,
    active: true,
    category_id: entradas.id
  },
  # Platos principales
  %{
    name: "Hamburguesa Clásica",
    description: "Carne 200g, queso cheddar, lechuga, tomate y cebolla",
    price: 12.00,
    stock: 20,
    active: true,
    category_id: platos.id
  },
  %{
    name: "Pizza Pepperoni",
    description: "Pizza mediana con pepperoni y queso mozzarella",
    price: 14.00,
    stock: 15,
    active: true,
    category_id: platos.id
  },
  %{
    name: "Pasta Alfredo",
    description: "Pasta con salsa alfredo y pollo",
    price: 13.00,
    stock: 12,
    active: true,
    category_id: platos.id
  },
  %{
    name: "Tacos de Carne",
    description: "3 tacos de carne asada con cebolla y cilantro",
    price: 10.00,
    stock: 18,
    active: true,
    category_id: platos.id
  },
  # Postres
  %{
    name: "Cheesecake",
    description: "Cheesecake de fresa con base de galleta",
    price: 6.50,
    stock: 10,
    active: true,
    category_id: postres.id
  },
  %{
    name: "Helado de Vainilla",
    description: "Helado artesanal de vainilla",
    price: 4.00,
    stock: 15,
    active: true,
    category_id: postres.id
  }
]

Enum.each(products, fn product_attrs ->
  existing = Catalog.list_products() |> Enum.find(fn p -> p.name == product_attrs.name end)

  if is_nil(existing) do
    case Catalog.create_product(product_attrs) do
      {:ok, product} -> IO.puts("  Created product: #{product.name} ($#{product.price})")
      {:error, changeset} -> IO.puts("  Error creating product: #{inspect(changeset.errors)}")
    end
  else
    IO.puts("  Product already exists: #{existing.name}")
  end
end)

IO.puts("Seeding complete!")
