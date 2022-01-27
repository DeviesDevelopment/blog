---
title: "Trying out AWS Timestream"
date: 2021-12-22T15:50:15+01:00
tags: [AWS, Timestream, Python]
featured_image: ""
description: "Trying out AWS Timestream in a small side project"
slug: "aws-timestream"
---

AWS recently (last year) released their new server-less database focused purely on time series data, Amazon Timestream. On their product page, AWS describes the database like:

 *"Amazon Timestream is a fast, scalable, and serverless time series database service for IoT and operational applications that makes it easy to store and analyze trillions of events per day up to 1,000 times faster and at as little as 1/10th the cost of relational databases."* 

I wanted to find out **how easy** it was to use and if the cost would be negligible for a side project with very little traffic. 

## Explanation of test data

There's a new bridge between Hisingen and the mainland of Gothenburg called Hisingsbron. For large cargo ships and tall sailboats, a bridge opening needs to happen that causes the traffic to stop. Kindly, the city of Gothenburg offers an API for checking whether the bridge is open or closed at the moment you ask. I will use the bridge status over time as time-series data for trying out Amazon Timestream. A data example entry looks like this: 

```
{
    timestamp: "2021-12-08 07:40:08",
    status: "Open"
}
```

## Is AWS Timestream easy to use?

I wanted to use Python to manage the Timestream database since it is the most widely used data science programming language in the world today. The documentation for using the Timestream database consists only of [code samples](https://docs.aws.amazon.com/timestream/latest/developerguide/code-samples.html) (good code samples though!). But, here are my takeaways from managing a Timestream database using Python.

**Getting started**

- The official AWS SDK for Python is called **[Boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)**.
    - The authentication to AWS is handled smoothly using AWS profiles or environment variables. No authentication is needed to be part of the actual code.
- The SDK supports CRUD operations on the database itself.
    - Listing tables, deleting tables, deleting databases, and much more.
- Writing and reading operations requires two different clients that are created like:

```python
SESSION = boto3.Session()
CLIENT_CONFIG = Config(
    read_timeout=20, max_pool_connections=5000, retries={"max_attempts": 10}
)

CLIENT_WRITE = SESSION.client("timestream-write", config=CLIENT_CONFIG)
CLIENT_QUERY = SESSION.client("timestream-query")
```

**Writing a record**

- A record in an AWS Timestream has the following attributes:
    - **Dimension:** Metadata in the form of key-value pairs.
    - **MesaureName:** The name of the measure, for instance, the name of the bridge.
    - **MeasureValue:** The value to be stored. In this example Open or Closed.
    - **MeasureValueType:** Type of the Value.
    - **Time**: The timestamp.
    
    This way of defining a record makes it very user-friendly for collecting data from multiple sources. If one collects data from 10 different bridges, the data can then be stored together, but separated on **MeasureName** and Dimension. There are no requirements that all records need to have the same **MeasureValueType,** etc. Here's a snippet for writing records to a table.
    
    ```python
    records = [
    	{
        "Dimensions": [{"Name": <MetaDataName>, "Value": <MetaDataValue>}]
        "MeasureName": "Hisingsbron",
        "MeasureValue": <value>,
        "MeasureValueType": "VARCHAR",
        "Time": <timestamp>,
    	}
    ]
    try:
    	result = CLIENT_WRITE.write_records(
    	  DatabaseName=DATABASE_NAME,
    	  TableName=TABLE_NAME,
    	  Records=records,
    	  CommonAttributes={},
    	)
      result_status_code = result["ResponseMetadata"]["HTTPStatusCode"]
      LOGGER.info(f"Writing ended with status {result_status_code}")
    except CLIENT_WRITE.exceptions.RejectedRecordsException as err:
        LOGGER.exception("Failed to write to database")
    ```
    
    Executing the above write will end up like this in the table:
    
    |  MetaDataName | mesaure_name |    time   | measure_value::varchar |
    |:-------------:|:------------:|:---------:|:----------------------:|
    | MetaDataValue | Hisingsbron  | timestamp | value                  |

**Reading a record** 

- AWS Timestream has a query language that is very similar to SQL but more optimized for time series data. The query for fetching the data for the last X days looks like this:

```sql
SELECT "measure_value::varchar", "time" FROM <database_name>.<table_name> WHERE time >= AGO(Xd)
```

 The above query can be executed using Python as:

```python
pages = []
try:
    page_iterator = CLIENT_QUERY.get_paginator('query').paginate(QueryString=<sql_query>)
    for page in page_iterator:
        pages.append(page)
except Exception as err:
    print("Exception while running query:", err)

```

**Deleting and modifying records**

* It is possible to modify entries in the database but currently, AWS Timestream does not support the deletion of entries. Yet.

## Is the cost negligible for a project like this?

The pricing model for AWS Timestream can be found [here](https://aws.amazon.com/timestream/pricing/), but relevant information for a use-case like this example is:

**Writes:**  1 million write of 1KB size ⇒ $0.6035

**Queries:** Per GB scanned ⇒ $0.012

I've collected data for 3 months which corresponds to ~**3000 records,** and the database is queried ~15 times a day for **~1000** records each time. 

The total cost has been $0.01, meaning that the cost is very negligible!

## Conclusion

AWS Timestream should be considered when choosing a database for time series data. It feels like it is made for gathering data from multiple to facilitate further analysis. With reasonable amounts of data (whatever that is), the price seems to be good, and for minimal side projects, the price is very good. The drawback is that it does not support the deletion of records but it will probably be a feature in the future.

By Fredrik Mile
