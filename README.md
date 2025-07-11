# MiniECommerce
- Mini Ecommerece application.
- supports sorting, filtering, pagination
- live/current product view count
- live updates on Inventory changes

## Techstack used
 - Elixir + Phoenix Liview

## To Run the application in local
- clone the Repo 
  - git clone https://github.com/ramannikhil/mini_e-commerce.git
  - Run below commands

    ```
      - cd mini_e_commerce/
      - mix deps.get
      - mix ecto.create
      - mix ecto.migrate

      - to seed the database run
      - mix run priv/repo/seeds.exs

        Lastly run this to start the application local server (runs in IEX console)
      - iex -S mix phx.server 

      - to run tests, use
      - mix test

    ```

 ## Routes
    - To get all the routes run
      -  mix phx.routes
    ```
        GET     /                                      MiniECommerceWeb.PageController :home
        GET     /login                                 MiniECommerceWeb.SessionController :new
        POST    /session                               MiniECommerceWeb.SessionController :create
        DELETE  /logout                                MiniECommerceWeb.SessionController :delete
        GET     /live/list                             MiniECommerceWeb.Product.List nil
        GET     /live/detail/:id                       MiniECommerceWeb.Product.Detail nil
        GET     /live/admin/home                       MiniECommerceWeb.Admin.Home nil
        GET     /live/admin/products/create            MiniECommerceWeb.Admin.Product.Create nil
        GET     /live/admin/products/update            MiniECommerceWeb.Admin.Product.Update nil
        GET     /live/admin/products/delete            MiniECommerceWeb.Admin.Product.Delete nil
        GET     /live/admin/inventory/create           MiniECommerceWeb.Admin.Inventory.Create nil
        GET     /live/admin/inventory/update           MiniECommerceWeb.Admin.Inventory.Update nil
    ```   

- Images references
  ### Products
  #### List Page

    - ![alt text](/priv/images/list1.png)

    - ![alt text](/priv/images/list2.png)

    - ![alt text](/priv/images/list3.png)

    - Sharable URL
    - ![alt text](/priv/images/list_url.png)

   - Product Detail Page 

    - ![alt text](/priv/images/detail1.png)

    - Successfully added to Cart
    - ![alt text](/priv/images/detail_added_to_cart.png)
    
    - Live counter updates
    - ![alt text](/priv/images/detail_count.png)


  ## Admin Section
  - Login Page
    - ![alt text](/priv/images/login.png)

  - Home page 
    - ![alt text](/priv/images/admin_home.png)

  - Create, Update, Delete Product
    - ![alt text](/priv/images/create_product.png)

    - ![alt text](/priv/images/update_product.png)

    - ![alt text](/priv/images/delete_product.png)

  - Create, Update Inventory
    - ![alt text](/priv/images/create_inventory.png)
    - ![alt text](/priv/images/update_inventory.png)
