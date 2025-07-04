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
      "thumbnail" =>
        "https://images.manning.com/book/0/8956122-acbd-4df6-bf93-78701555c171/Juric-3ed-HI.png",
      "price" => "45.99",
      "category" => "books"
    },
    %{
      "name" => "Phoenix for Beginners",
      "description" => "Intro to Phoenix framework.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61i6VBUfMCL._SY466_.jpg",
      "price" => "39.50",
      "category" => "books"
    },
    %{
      "name" => "Programming Elixir",
      "description" => "Deep dive into Elixir language.",
      "thumbnail" => "https://m.media-amazon.com/images/I/51xpLBNJgjL._SY445_SX342_.jpg",
      "price" => "49.99",
      "category" => "books"
    },
    %{
      "name" => "Introducing Elixir ",
      "description" => "Introducing Elixir language.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61l6vP0OifL._SY385_.jpg",
      "price" => "29.99",
      "category" => "books"
    },
    %{
      "name" => "Elixir & Phoenix in Action",
      "description" => "Build Scalable, Concurrent, and Real-Time",
      "thumbnail" => "https://m.media-amazon.com/images/I/617yMlDeLFL._SY522_.jpg",
      "price" => "19.99",
      "category" => "books"
    },
    %{
      "name" => "Smartphone X1",
      "description" => "High-res display smartphone.",
      "thumbnail" => "https://m.media-amazon.com/images/I/81nt-RGKpyL._AC_UY218_.jpg",
      "price" => "699.99",
      "category" => "electronics"
    },
    %{
      "name" => "Wireless Headphones",
      "description" => "Noise-cancelling headphones.",
      "thumbnail" => "https://m.media-amazon.com/images/I/51vnDUdRY-L.jpg",
      "price" => "120.00",
      "category" => "electronics"
    },
    %{
      "name" => "Bluetooth Speaker",
      "description" => "Portable and loud.",
      "thumbnail" => "https://m.media-amazon.com/images/I/81nT721hWGL._SX522_.jpg",
      "price" => "75.49",
      "category" => "electronics"
    },
    %{
      "name" => "HP OmniBook 5",
      "description" => "QC Snapdragon X1-26-100 Next Gen AI Laptop, (16GB LPDDR5x)",
      "thumbnail" => "https://m.media-amazon.com/images/I/71fHNU8KnQL._SX679_.jpg",
      "price" => "475.49",
      "category" => "electronics"
    },
    %{
      "name" => "Sony Alpha ZV-E10L",
      "description" => "24.2 Mega Pixel Interchangeable-Lens Mirrorless vlog Camera.",
      "thumbnail" => "https://m.media-amazon.com/images/I/71AJ6LicHkL._SX679_.jpg",
      "price" => "1075.49",
      "category" => "electronics"
    },
    %{
      "name" => "Men's Jacket",
      "description" => "Waterproof winter jacket.",
      "thumbnail" => "https://m.media-amazon.com/images/I/51XWUBbfe7L._AC_UL320_.jpg",
      "price" => "150.00",
      "category" => "clothing"
    },
    %{
      "name" => "Women's T-shirt",
      "description" => "100% cotton crew neck.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61fFbbOwLxL._AC_UL320_.jpg",
      "price" => "25.00",
      "category" => "clothing"
    },
    %{
      "name" => "Unisex Hoodie",
      "description" => "Comfortable and warm.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61vQYGLUnZL._AC_UL320_.jpg",
      "price" => "49.99",
      "category" => "clothing"
    },
    %{
      "name" => "ASIAN Men's Sports",
      "description" => "Running Shoes",
      "thumbnail" => "https://m.media-amazon.com/images/I/61utX8kBDlL._SY695_.jpg",
      "price" => "125.50",
      "category" => "clothing"
    },
    %{
      "name" => "Safari Omega spacious",
      "description" => "Large laptop backpack with Raincover, college bag",
      "thumbnail" => "https://m.media-amazon.com/images/I/71maWXZscfL._SX522_.jpg",
      "price" => "179.99",
      "category" => "clothing"
    },
    %{
      "name" => "Protein Bars",
      "description" => "Box of 12 protein bars.",
      "thumbnail" => "https://m.media-amazon.com/images/I/71Cyz1OOArL._AC_UL320_.jpg",
      "price" => "24.99",
      "category" => "food"
    },
    %{
      "name" => "Organic Honey",
      "description" => "Raw unfiltered honey.",
      "thumbnail" => "https://m.media-amazon.com/images/I/81zHR0l51XL._AC_UL320_.jpg",
      "price" => "42.49",
      "category" => "food"
    },
    %{
      "name" => "Almond Butter",
      "description" => "Creamy and nutritious.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61CMfen0TzL._AC_UL320_.jpg",
      "price" => "15.00",
      "category" => "food"
    },
    %{
      "name" => "KitchenSmith Dried Blueberry",
      "description" => "Seedless - 250gm | USA Origin - Dried Blueberries",
      "thumbnail" => "https://m.media-amazon.com/images/I/810Dd+lYN+L._SX679_.jpg",
      "price" => "45.00",
      "category" => "food"
    },
    %{
      "name" => "7 BAZAARI Date & Nut Bites ",
      "description" => "Creamy Nuts.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61XXUAccfHL._SX679_.jpg",
      "price" => "22.00",
      "category" => "food"
    },
    %{
      "name" => "Running Shoes",
      "description" => "Durable sports shoes.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61md3szAgLL._AC_UL320_.jpg",
      "price" => "89.99",
      "category" => "sports"
    },
    %{
      "name" => "Yoga Mat",
      "description" => "Non-slip surface.",
      "thumbnail" => "https://m.media-amazon.com/images/I/612K2lgbyIL._AC_UL320_.jpg",
      "price" => "35.00",
      "category" => "sports"
    },
    %{
      "name" => "Dumbbell Set",
      "description" => "Adjustable 20kg set.",
      "thumbnail" => "https://m.media-amazon.com/images/I/71uneWbTPpL._AC_UL320_.jpg",
      "price" => "79.99",
      "category" => "sports"
    },
    %{
      "name" => "Boldfit Skipping Rope",
      "description" => "Jumping Rope With Adjustable Height",
      "thumbnail" => "https://m.media-amazon.com/images/I/71l2-gWOnpL._SX679_.jpg",
      "price" => "24.45",
      "category" => "sports"
    },
    %{
      "name" => "FitBox Sports Adjustable",
      "description" => "Hand Grip Strengthener.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61rUI3ktxaL._SX679_.jpg",
      "price" => "12.99",
      "category" => "sports"
    },
    %{
      "name" => "Organic Baby Food",
      "description" => "Healthy organic food.",
      "thumbnail" => "https://m.media-amazon.com/images/I/71tDu+LzGhL._AC_UL320_.jpg",
      "price" => "15.50",
      "category" => "baby"
    },
    %{
      "name" => "Baby Diapers",
      "description" => "Pack of 50 diapers.",
      "thumbnail" =>
        "https://m.media-amazon.com/images/I/41FukaZkGXL._SX300_SY300_QL70_FMwebp_.jpg",
      "price" => "29.99",
      "category" => "baby"
    },
    %{
      "name" => "Baby Shampoo",
      "description" => "Tear-free formula.",
      "thumbnail" => "https://m.media-amazon.com/images/I/71+sCbLGj7L._SX679_.jpg",
      "price" => "7.99",
      "category" => "baby"
    },
    %{
      "name" => "EQUALSTWO Baby Cleansing Bar",
      "description" => "Baby Soaps for Bath, All Skin Types.",
      "thumbnail" => "https://m.media-amazon.com/images/I/61Skl-JCUtL._SX522_.jpg",
      "price" => "17.99",
      "category" => "baby"
    },
    %{
      "name" => "OYO BABY Anti-Piling Fleece",
      "description" => "Absorbent Instant Dry Sheet for Baby",
      "thumbnail" =>
        "https://m.media-amazon.com/images/I/81h1hsPk7PL._SX679_PIbundle-3,TopRight,0,0_AA679SH20_.jpg",
      "price" => "88.99",
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
