# Clone prod PostgreSQL database to dev safely

Before deploying anything to production it can be very helpful to make sure that your changes and potential database migrations won't resulut in data loss or data corruption.
One way of solving this problem is to try out the changes and migrations in a dev environemnt beforehand but this requires that the database used in dev is a copy of the database in production.


## Assumptions

Something about old projekt bla bla bla, maintainence etc etc. 

In production, the application communicates with a PostgreSQL server running in Azure.

In dev, the application communicates with a PostgreSQL running in docker on the same virtual machine as the application itself.


## Step 1: Create a backup of the database in production

Tools needed: PgAdmin 4

Since the database server is hosted in Azure we most certanly need to whitelist our IP address to gain access to the server from our local machine.
Navigate to the PostgreSQL server resource in the Azure portal and whitelist your IP address under Connection Security.

Open up PgAdmin 4 and create a new connection.
Almost all required information can be found from the connection string found in the Azure Portal, like `hostname (something.postgres.database.azure.com)`, `user`, `databasename` and wether or not ssl is required.
The password can hopefully be fetched from somewhere secured.
Once connected to the server, right click on the database and and press `backup` and choose `tar` or `folder` format and wait a few minutes. You should now have a backup file on your local machine, please make sure that the file ending of the file is `.backup`.

Before you forget, remove your IP from the whitelisted IP addresses under Connection Security in the Azure Portal.

## Step 2: Connect to the dev postgreSQL server

Since this postgreSQL server runs in docker on a Virtual Machine hosted in Azure we need to open up the `5432` port,  which is the default port for postgreSQL port on the machine.
By running `docker ps` you should be able to see the port mappings for the PostgreSQL sever and identify which port you need to open up for inbound connections.
In the Azure Portal, navigate to the network security group used by your virtual machine and go to Inbound Security Rules under settings. Add a new security rule `PostgreSQL` as service and set the correct destionaton port ranges.

To try the connection you can run: 

`psql -h <public-ip-of-VM> -p <5432 or the used port> -U <database-username>`

If you manage to connect, disconnect and open up PgAdmin again.
Create a new connection. This time, the host is the public ip of the virtual machine.

## Step 3: Apply the production backup on the dev database

The backup we created from the production database contains more that just domain data.
This backup contains information about database users and roles. To be able to restore the backup we need to have the same users and roles in the dev database, otherwise we won't be able to fufill the restore.
Let's assume that the name of the database that we took a backup of in prod was `xxxx` and the user with full access on the database server was `yyyy`.

We can create the `yyyy` user in the dev database by running:

```
CREATE ROLE yyyy WITH
  LOGIN
  SUPERUSER
  INHERIT
  CREATEDB
  CREATEROLE
  REPLICATION
  ENCRYPTED PASSWORD '<some encrypted password>';
```

Now that we have the `yyyy` user we can create `xxxx` database. If the `xxxx` database already exists, we need to remove it first. Assuming that there are applications connected to this dev database we need to kill all those connections before we can continue with the deletion.

Kill the connections by running:

```
SELECT pid, pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = current_database() AND pid <> pg_backend_pid();
```

Prevent future connection by running:

```
REVOKE CONNECT ON DATABASE xxxx FROM public;
```

You should now be able to right click on the database and delete/drop it.
When the database is removed, right click on the server and create a new database.
Set the name to `xxxx` **and** the owner to `yyyy`.
Once the database is created, right click on `xxxx` and press `restore...`. Set the format to `Custom or tar` and the filename should be the `.backup` file created in step 1.
The role name needs to be user/role `yyyy` and press restore.
You should now have a snapshot of the production database running in your dev environment.
As the absolute last thing, restore the access to the database by running:

```
GRANT CONNECT ON DATABASE xxxx TO public;
```
