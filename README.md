# Pimcore Demo in docker-compose #

This is a repo to quickly setup a pimcore demo or development environment for pimcore installations.
It is meant as a proposal to the pimcore company to replace the existing docker repo

### What is this repository for? ###

* Quickly setup a demo of pimcore
* Quickly setup a development environment to start hacking away at a pimcore installation
* Serve as a basis to setup a production environment for pimcore in docker-compose

### Requirements ###

* docker >= 1.10
* docker-compose >= 1.8

### I just want to give pimcore a spin, take me to the fast lane! ###

* git clone https://github.com/Riodigital-de/docker-pimcore-demo-standalone.git _/whereTheFilesForYourPicmoreStackShouldBe_
* cd _/whereTheFilesForYourPicmoreStackShouldBe_ 
* docker-compose up

That's it.

The build of the php container and download of the pimcore files on the first run can take some time however.
Watch the output of docker-compose, once the php container reports _ready to handle connections_, you are good to go :)

Either go to

* http://IP-OR-HOSTNAME-OF-DOCKER-HOST/

or go straight to the admin interface

* http://IP-OR-HOSTNAME-OF-DOCKER-HOST/admin
with Username: admin and Password: demo

Alternatively you can configure your local systems host file to point one or more of the domains defined in the .env file under nginx -> server_names to point the IP of your Docker Host and use the domains to access the pimcore demo. 
This is especially useful if you want to test multi-domain / multi-language setups.

### Configuring the setup ###

Basically the only file you need to look at is **_.env_** in the root directory. With the settings in there, you will have a range of options to choose from.

By default, .env is configure as such:

* The databases root password is 'root'
* the default database user is 'pimcore', the table for pimcore is 'pimcore', the pimcore users password is 'pimcore'
* the pimcore /php container is build using the phusion-compressed Dockerfile
* when the docker-compose stack is run, it will check whether there are any files in data/pimcore (as seen from your machine) or /var/www/picmore (from within the php container)
    * if not, it will download pimcore with the sample data installed and set it up
    * if there are files (besides .gitignore) it will use the existing files and skip the download and setup
* php will use redis to cache, but not memcached
* php will log php errors to the docker logs, but not php access
* php will install all recommended and additional software to run pimcore
* the nginx proxy server will listen to pimcore-demo.de, pimcore-demo.at and pimcore-demo.com
* backups are created daily (at 02:00 am) and are AES-256 encrypted using the passphrase defined in _/config/backup/gpgPassPhrase_

At the moment, all options in php except _pimcore_sample_data_ must trigger a rebuild of the php image to take effect, all other options take effect every time you run docker-compose up.

### What's the point of having 4 different Dockerfiles for the php / pimcore container? ###

The reasoning behind this is to leverage easy of use versus image size.

There are two basic flavors for the php image: 
One is based on [phusion/baseimage](https://hub.docker.com/r/phusion/baseimage/), an image based on Ubuntu, designed for use in docker, 
the other is based on [alpine edge](https://hub.docker.com/_/alpine/)

Pimcore profits heavily from php7. Although php7 has been out for quite some time now, when it comes to availability of extension that are compatible with php7, the situation is still somewhat grim.
The phusion/Ubuntu based images utilize community repositories that allow you to get almost everything you need by simply adding the repositories to the apt sources, while resulting in larger image sizes.
Alpine is known for being small in size, however a lot of necessary components must still be compiled from source, as even in edge, there aren't too many php7-ready extensions available.
(To be fair, with the alpine image with all additional software installed also hovering around 1 gigabyte, we are really pushing the boundary on _"small"_ here)
 
This means: If you want to fiddle around, or just get things going, use the phusion based images.
If image size is a concern and you've used gcc before, go with the alpine based images.

Each of the two flavors also comes in two variants: Compressed and uncompressed.
Take a look at the both an uncompressed and compressed Dockerfile:
In the uncompressed variants, almost every logical build instruction is formulated as an individual RUN statement. This is useful for development and debugging: Should you want to customize the image, that is you make changes to the Dockefile, and something goes wrong, having one build instruction per logical statement means drastically lower build times on retries, since docker can utilize its build cache and just pick up from where-ever the error occurred.

Since every layer in the build cache adds another layer to the final image, having so many statements und thus so many layers means the resulting images will however be really massive.
This is where the compressed images come in:
As opposed to the uncompressed variants with their numerous statements, almost every logical statement has been formulated as one long, single RUN instruction.
This means having fewer layers und thus smaller images. The trade-off is when-ever something in the single, long statement causes the build to break, docker has to do the complete statement again, even if the error was in the very last line.

The recommended workflow is this:
If you want to customize the images, first try out the changes in the uncompressed variant, build it, and check if everything works properly.
If that's the case, backport your modifications to the compressed variant.

### Who do I talk to? ###

* [bernd.konrad@riodigital.de](mailto:bernd.konrad@riodigital.de?subject=PimcoreDockerComposeDemo)