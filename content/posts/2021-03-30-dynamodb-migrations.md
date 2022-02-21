---
categories:
  - Implementation
  - Refactoring
tags:
  - AWS
  - DynamoDB
date: "2021-03-30T10:34:41Z"
title: Migrating data between DynamoDB tables
author:
  - Gustav Sundin
  - Rickard Andersson
---

When setting up a new DynamoDB table, an important decision is to decide what primary key to use. However, it’s not uncommon to not have the full picture up front and therefore it could be hard to make the right decision beforehand. While the [official AWS documentation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-general-nosql-design.html) states that _“you shouldn’t start designing your schema for DynamoDB until you know the questions it will need to answer”_, you often need to experiment to be able to discover what those questions are. Luckily there is an easy approach for how to migrate to a new key schema that we will describe in this blog post.

In short, the process looks like this:

1. Create the target table
2. Synchronize incoming changes to the target table using [DynamoDB Streams](https://aws.amazon.com/blogs/database/dynamodb-streams-use-cases-and-design-patterns/)
3. Migrate existing items
4. Start reading from the target table
5. Start writing to the target table
6. Delete the original table

Changing key schemas is not the only use case for this method. The same approach can also be used to split or merge multiple tables, to manipulate data items, or to get rid of unwanted data. The main advantages of this approach is that it requires no downtime, is easily reversible, and guarantees that no data is lost during the migration process.

This blog post also comes with a [companion example repo](https://github.com/DeviesDevelopment/dynamodb-migration).

_Note that if you’re simply looking for replicating a table over multiple regions, you should have a look at [DynamoDB Global Tables](https://aws.amazon.com/dynamodb/global-tables/) instead._

## Create target table

Before we begin with the actual migration, the target table needs to be in place. Create this table as you normally would, using CloudFormation or elsewise.

## Synchronize changes using DynamoDB Streams

Before we can start using the target table, we need to migrate the data. In our approach we use [DynamoDB Streams](https://aws.amazon.com/blogs/database/dynamodb-streams-use-cases-and-design-patterns/), which is an AWS managed stream of change events that happen to a DynamoDB table. The stream is guaranteed to contain all events in a time-ordered sequence, meaning that we can guarantee that no data loss will occur during the migration.

To actually migrate data, something needs to be triggered on the change events. For this we use an AWS Lambda function. The function gets the change event as input, and will apply the corresponding change to the target table. For a concrete code example, see [this repo](https://github.com/DeviesDevelopment/dynamodb-migration).

Note that if any transformation of the item needs to be made, it should happen here in the Lambda function. As stated, this could be anything from one-to-one mapping into a new data format to splitting up the data across multiple target tables.

An alternative to using DynamoDB Streams is to use [AWS Data Pipeline](https://aws.amazon.com/datapipeline/), which might be better suited for cross account migrations.

## Migrate existing items

Now that we have our stream in place, we can be certain that any changes in the original table will be propagated to the target table. We can also leverage the same stream to migrate all the existing data as well. This is as simple as writing a script that makes some update to every item in the original table, meaning that every item will also end up on the DynamoDB stream. This could be as easy as adding some property (such as the “migrate” property in our [example](https://github.com/DeviesDevelopment/dynamodb-migration)), which is trimmed off in the Lambda function before the item is written to the target table.

## Update code to read from target table

At this point we are certain that every item in the original table has been written to the target table, and that any new changes are propagated to the target table. The next step is to update application code to actually read from the target table. There is no need to change all application code at once since both original and target tables will contain the same data (note that there might be a short delay until any written data is available in the target table).
Update code to write to target table

The next step is to update application code so that it writes to the target table as well. Before we do this we need to be certain that nothing is still reading from the old table. The best way to ensure this is to look at the read capacity metric in the AWS console. Just like with the read operations, there is no need to change everything at once.

## Delete original table

Once all application code is updated to write to the target table, the original table is not used anymore and can be deleted. Before doing so, it could be a good idea to monitor the read and write capacity metrics for a while to make sure you haven’t missed anything.

The approach described in this blog post is a safe and relatively easy way to migrate data between DynamoDB tables. Thus, it’s not completely true that _“you shouldn’t start designing your schema for DynamoDB until you know the questions it will need to answer”_. On the contrary, it is actually quite straightforward to make changes to an existing key schema, as long as you do it in a controlled manner. This allows for experimentation and iterative development in any DynamoDB-backed application.

By Gustav Sundin & Rickard Andersson
