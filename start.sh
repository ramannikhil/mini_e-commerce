#!/bin/bash
/opt/app/bin/mini_e_commerce eval MiniECommerce.Migrator.migrate
/opt/app/bin/mini_e_commerce eval MiniECommerce.Migrator.seed_data
/opt/app/bin/mini_e_commerce start