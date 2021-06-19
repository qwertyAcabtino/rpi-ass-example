# Raspberry PI as a service (RPI-AAS)

Some example repository of how to manage your rpi's services in docker in a single command.  

The basic use case is when you have a rpi with several services like mail, rss, music, torrent, etc.  
Given that, you can setup every service in a safe manner, using different passwords for each service and storing all of them in a keepass file.  

The keepass file is created on the fly and the password is only shown once on screen, the rest of the password, the one used by each individual service is passed from the terminal to every running container via a docker secret (does a `docker swarm init` in order to be capable of do so).

## Some system requirements

+ Docker
+ Docker swam (installed by default along with docker in many cases)
+ Docker-compose (installed by default along with docker in many cases)
+ Keepass

## How to use this repo

```
git clone 
cd ~/dev/../rpi-ass/
bash bash/install.sh
docker ps
# Also check the pass.kbdx file

```

## But...i already have a keepass file in use

No problem. Keepass has a feature where two different files can be merge into one (or transferred as you prefer).  


## But...I don't need fresh-rss, but some other juicy stuff

Virtually, any new service can be added by:  

+ Creating a new folder insider the `./services` folder  
+ Place your docker-compose inside  
+ Edit the `bash/install.sh` file, adding something like the following at the bottom:  

```
# Set up fresh rss
add_secret_entry "rpi-aas-XXX-password" "rpi_aas_XXX_password" $MASTER_PASSWORD $KEEPASS_DATABASE_FILE
cd ./services/XXX
# Here place any command, like folder creation or so
docker-compose down
docker-compose rm
docker-compose up -d --force-recreate
cd ../../
```