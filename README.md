# To run migration

## Nuke migration/target database
First nuke entire migration database with:
```bash
make Makefile.Reset reset
```

## Create foundation

```bash
# 1. Create Databases dev & prod
make -f Makefile.InitialSetup initialize
```
