---
title: "Mitigating Primitive Obsession in ASP.NET Web Api"
date: 2022-07-27T15:20:58+02:00
tags: [ "ASP.NET", ".NET", "code smells" ]
featured_image: ""
description: ""
slug: "mitigating-primitive-obsession-in-asp.net-web-api"
author:
 - Carina Fernandes
 - Rickard Andersson
 - Johan Hage
---
   One of the projects we work with at Devies is related to the dental domain.
   In that project we use the [dental notation (ISO 3950)](https://en.wikipedia.org/wiki/Dental_notation) to refer to teeth. 
   Every tooth have an unique identifier that consist of two characters.
   The first character represent a quadrant (one of four areas in the mouth).
   The second character is an identifier that refers to one of the eight teeth in that area.
   
   Early on in the project we represented the tooth identifier using a string, for example `"42"` (4 is the quadrant, 2 is the identifier).
   As the project grew we stared to use this tooth identifier in many different places in the project.
   Since we use a raw string, we had to make sure the tooth identifier was properly validated at every place where it was used.
   Additionally, it was unclear what the tooth identifier (string) represented, and it affected the readability of our code.
   
   This is a clear example of [primitive obsession](https://refactoring.guru/smells/primitive-obsession).
   Primitive Obsession is a code smell in which primitive data (such as string, int, char etc) types are used excessively to represent your data models.
   In this post we will describe how we mitigated this problem in the context of ASP.Net Web API where we use Entity Framework.

   ### ToothIdentifier
   First of all, we introduced a new model, `ToothIdentifier`. The model includes validation to get rid of duplicating the same code over and over again.

```csharp
 public record ToothIdentifier

    public ToothIdentifier(string? id)
    {
        // Bunch of validation logic that has not been included for brevity
        Id = id;
    }

    private string Id { get; }

    public override string ToString()
    {
        return Id;
    }
}
```
   That's a great start! We can now clearly refer to a `ToothIdentifier`. Everytime we use the record, we know that it's a tooth identifier and that it has been properly validated.
   Next, we want to be able to use our record as seamlessly as possible throughout the codebase.

   ### Conversion for Entity Framework
   In our project we use Entity Framework for object-relational mapping to our database.
   We store the tooth identifier in our database as a string, and that's perfectly fine.
   However, we want the benefits of using our `ToothIdentifier` record in our database-related code.
   Entity framework knows perfectly well how to store a string in the database, but it has no idea of how to store a `ToothIdentifier`.
   We had to in some way convert our `ToothIdentifier` model to a string when we are reading and writing to the database, that is exactly what [Value Conversions](https://docs.microsoft.com/en-us/ef/core/modeling/value-conversions?tabs=data-annotations) do.
   
   This example shows how we implemented our converter.
   We extend the ValueConverter interface and take both types, `ToothIdentifier` and string.
   We define a function that converts our model, `ToothIdentifier` to a string in the database and the other way around.

```csharp
public class ToothIdentifierConverter : ValueConverter<ToothIdentifier, string>
{
    public ToothIdentifierConverter()
        : base(
            v => v.ToString(),
            v => new ToothIdentifier(v))
    {
    }
}
```

   ### Conversion for JSON serialize/deserialize
   Our project is a primarily a Web API.
   Naturally, we have a bunch of HTTP endpoints that handles JSON payloads.
   For JSON marshalling we use [`System.Text.Json`](https://docs.microsoft.com/en-us/dotnet/api/system.text.json?view=net-6.0), but that library has no idea of how to convert a `ToothIdentifier`.
   To have it understand what to do with `ToothIdentifier` we must implement a JsonConverter<T>.

   With a JsonConverter in place, we can use `ToothIdentifier` in our request/response models, without having to worry about validation.

   Note that you also must register JsonConverters. See [link](https://docs.microsoft.com/en-us/dotnet/standard/serialization/system-text-json-converters-how-to?pivots=dotnet-6-0#register-a-custom-converter) for full documentation.

```csharp
public class ToothIdentifierConverter : JsonConverter<ToothIdentifier>
{
    public override ToothIdentifier Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        var value = reader.GetString();
        try
        {
            return new ToothIdentifier(value);
        }
        catch (ToothIdentifierInvalidException e)
        {
            throw new JsonException(e.Message);
        }
    }

    public override void Write(Utf8JsonWriter writer, ToothIdentifier value, JsonSerializerOptions options)
    {
        writer.WriteStringValue(value.ToString());
    }
}

```
### Model binding

   In our API, we don't only use tooth identifiers in JSON payloads.
   We also use them in HTTP request paths and form data.
   Therefore, we also want to use the new `ToothIdentifier` record in our controller methods, as in below sample code.

```csharp
    [HttpPost]
    [Route("/reviews/{toothId}")]
    public async Task<ActionResult> TestBackgroundNotification([FromPath] ToothIdentifier id)
    {
        ...
    }
```

   In order to have ASP.NET convert a regular string, e.g. "42" to a `ToothIdentifier` we must implement an `IModelBinder`.
   Below is how we implemented the ModelBinder. Note that we've removed some code for brevity. Documentation of how to fully implement one can be found [here](https://docs.microsoft.com/en-us/aspnet/core/mvc/advanced/custom-model-binding?view=aspnetcore-6.0#custom-model-binder-sample).

```csharp
public class ToothIdentifierBinder : IModelBinder
{
    public Task BindModelAsync(ModelBindingContext bindingContext)
    {
       ...
        try
        {
            var toothId = new ToothIdentifier(value);
            bindingContext.Result = ModelBindingResult.Success(toothId);
        }
        catch (ToothIdentifierInvalidException e)
        {
            bindingContext.ModelState.TryAddModelError(
                modelName, e.Message);
        }

        return Task.CompletedTask;
    }
}
```

### Swashbuckle

Now we can use the `ToothIdentifier` record seamlessly throughout our codebase.
However, we also want the API documentation clear and easy to use.
To generate Swagger documentation for our API we use [Swashbuckle](https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-swashbuckle?view=aspnetcore-6.0&tabs=visual-studio).
Swashbuckle does not know about the different converters we've implemented, and therefore show `ToothIdentifier` as an empty object.
There no possible way for a user to know how to provide a tooth identifier.

In order to instruct Swashbuckle how to represent `ToothIdentifier`, we used the AddSwaggerGen method to add information about how the input should be. 
With Swashbuckle we could add all the necessary information about our `ToothIdentifier`. 
Now every user would be able to use our API without having to figure out what the correct input is.

```csharp
services
    .AddSwaggerGen(c =>
    {
        c.MapType<ToothIdentifier>(() => new OpenApiSchema
        {
            Type = "string",
            MinLength = 2,
            MaxLength = 2,
            Example = new OpenApiString("11"),
            Description = "ToothIdentifier where first character refers to a quadrant of value 1-4, and the second character an identifier of value 1-8.",
            Pattern = "^[1-4][1-8]$"
        });
    })

```
This was a lot of work and added many lines of code, but now the readability to our project has improved quite a lot.
The validation for `ToothIdentifier` is in one place.
We no longer need to duplicate the validation code every time we used a tooth identifier (string). 

Errors now occur in the API layer.
That is earlier than before when errors could happen when getting the tooth information.
The API documentation is easier to understand and makes it possible for user to know how to make an request.  
  
