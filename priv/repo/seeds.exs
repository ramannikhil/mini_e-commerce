alias MiniECommerce.Schema.{Product, User, Inventory, ProductView}
alias MiniECommerce.Repo
import Ecto.Query
alias MiniECommerce.Service.Product, as: ProductService

# Users data
users = [
  %{name: "Admin", email: "admin@gmail.com", password: "1234", role: :admin},
  %{name: "test_user", email: "test@gmail.com", password: "1234", role: :visitor}
]

Enum.each(users, fn user ->
  %User{}
  |> User.changeset(user)
  |> Repo.insert!()
end)

# Products data
products =
  [
    %{
      "name" => "Elixir in Action",
      "description" => "Book on Elixir programming.",
      "thumbnail" => "https://images.unsplash.com/photo-1581090700227-1e8b918092c2",
      "price" => "45.99",
      "category" => "books"
    },
    %{
      "name" => "Phoenix for Beginners",
      "description" => "Intro to Phoenix framework.",
      "thumbnail" => "https://images.unsplash.com/photo-1581092334603-2ce882f1d45c",
      "price" => "39.50",
      "category" => "books"
    },
    %{
      "name" => "Programming Elixir",
      "description" => "Deep dive into Elixir language.",
      "thumbnail" => "https://images.unsplash.com/photo-1584697964403-e61a2ab27195",
      "price" => "49.99",
      "category" => "books"
    },
    %{
      "name" => "Smartphone X1",
      "description" => "High-res display smartphone.",
      "thumbnail" => "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9",
      "price" => "699.99",
      "category" => "electronics"
    },
    %{
      "name" => "Wireless Headphones",
      "description" => "Noise-cancelling headphones.",
      "thumbnail" => "https://images.unsplash.com/photo-1580894908361-967195033215",
      "price" => "120.00",
      "category" => "electronics"
    },
    %{
      "name" => "Bluetooth Speaker",
      "description" => "Portable and loud.",
      "thumbnail" => "https://images.unsplash.com/photo-1612817154859-56b0c0d3ec20",
      "price" => "75.49",
      "category" => "electronics"
    },
    %{
      "name" => "Men's Jacket",
      "description" => "Waterproof winter jacket.",
      "thumbnail" => "https://images.unsplash.com/photo-1618354691444-92f831cd5f3b",
      "price" => "150.00",
      "category" => "clothing"
    },
    %{
      "name" => "Women's T-shirt",
      "description" => "100% cotton crew neck.",
      "thumbnail" => "https://images.unsplash.com/photo-1520975922071-3c1f11fb8e4f",
      "price" => "25.00",
      "category" => "clothing"
    },
    %{
      "name" => "Unisex Hoodie",
      "description" => "Comfortable and warm.",
      "thumbnail" => "https://images.unsplash.com/photo-1602810318696-f918dc12a995",
      "price" => "49.99",
      "category" => "clothing"
    },
    %{
      "name" => "Protein Bars",
      "description" => "Box of 12 protein bars.",
      "thumbnail" => "https://images.unsplash.com/photo-1572449043414-6f3e5d010d41",
      "price" => "24.99",
      "category" => "food"
    },
    %{
      "name" => "Organic Honey",
      "description" => "Raw unfiltered honey.",
      "thumbnail" => "https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2",
      "price" => "12.49",
      "category" => "food"
    },
    %{
      "name" => "Almond Butter",
      "description" => "Creamy and nutritious.",
      "thumbnail" => "https://images.unsplash.com/photo-1617137968423-e8fcb0ef59b4",
      "price" => "15.00",
      "category" => "food"
    },
    %{
      "name" => "Running Shoes",
      "description" => "Durable sports shoes.",
      "thumbnail" => "https://images.unsplash.com/photo-1618354690501-b83e61d9612e",
      "price" => "89.99",
      "category" => "sports"
    },
    %{
      "name" => "Yoga Mat",
      "description" => "Non-slip surface.",
      "thumbnail" => "https://images.unsplash.com/photo-1583337130417-3346a1f6b1c2",
      "price" => "35.00",
      "category" => "sports"
    },
    %{
      "name" => "Dumbbell Set",
      "description" => "Adjustable 20kg set.",
      "thumbnail" => "https://images.unsplash.com/photo-1571019613914-85f342c1d4a7",
      "price" => "79.99",
      "category" => "sports"
    },
    %{
      "name" => "Organic Baby Food",
      "description" => "Healthy organic food.",
      "thumbnail" => "https://images.unsplash.com/photo-1600359735632-3c7f3b80c03f",
      "price" => "15.50",
      "category" => "baby"
    },
    %{
      "name" => "Baby Diapers",
      "description" => "Pack of 50 diapers.",
      "thumbnail" => "https://images.unsplash.com/photo-1583778179481-3e35f0f9d66f",
      "price" => "29.99",
      "category" => "baby"
    },
    %{
      "name" => "Baby Shampoo",
      "description" => "Tear-free formula.",
      "thumbnail" => "https://images.unsplash.com/photo-1631387410452-bad8328eac95",
      "price" => "7.99",
      "category" => "baby"
    }
  ]

Enum.each(products, fn product_data ->
  ProductService.create(product_data)
end)

# Seed inventory data using product id
products_list = from(x in Product, select: x.id) |> Repo.all()

inventory_params_list =
  products_list
  |> Enum.map(fn product_id ->
    %{
      product_id: product_id,
      current_quantity: Enum.random(10..20)
    }
  end)

inventory_params_list
|> Enum.each(fn inventory_data ->
  %Inventory{}
  |> Inventory.changeset(inventory_data)
  |> Repo.insert!()
end)

# Update Product views data, since it's already created while creating a product
from(x in ProductView)
|> Repo.all()
|> Enum.each(fn product_view ->
  count = Enum.random(5..20)

  ProductView.changeset(product_view, %{"count" => count})
  |> Repo.update!()
end)
