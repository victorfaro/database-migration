# To run migration

## Nuke migration/target database
First nuke entire migration database with:
```bash
make -f Reset.make reset-databases
```

## Create foundation

```bash
# 1. Create Databases dev & prod
make -f InitialSetup.make initialize
```
