make -f Reset.make reset-databases
make -f InitialSetup.make initialize
make -f ProdEducation.make dump_prod_education_all
make -f ProdEducation.make restore_prod_education_all
make -f Public.make dump_public_all
make -f Public.make restore_public_all
make -f PurchaseOrders.make dump_
