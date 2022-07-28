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

 - Introduction to problem
   - Concept central to domain that is represented as a primitive
   In one of the projects we work with in Devies, the dental notation (ISO 3950) is wide used to refer too teeth. 
   Every tooth have an unique identifier that consits of two characters.
   The first character represent the quadrant, one of four areas in the mouth.
   The second characters is an identifiers that refers to one of the eight teeth in that area.

   In the early on the project we represented the tooth identifier as a string, for example `"42"`
   As the project grow we stared to use this tooth identifier in many different places in the project.
   In every place where the identifier was used we had to make sure the tooth identifier was properly validated.
   The reuse of the string type made it unclear of what the tooth identifier represents, and it affected the readability of our code.
   
   This is a clear example of [primitive obsession]('insert-link').
   In this post we will describe how we mitigated this problem in the context of ASP.Net Webb API where we use Entity Framework.



   - Duplicated validation
   - Readability

 - Conversion for Entity Framework (ValueConverter)

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

 - Conversion for JSON serialize/deserialize (JsonConverter)

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
 - Model binding (controller routes, etc)

```csharp
public class ToothIdentifierBinder : IModelBinder
{
    public Task BindModelAsync(ModelBindingContext bindingContext)
    {
        if (bindingContext == null) throw new ArgumentNullException(nameof(bindingContext));

        var modelName = bindingContext.ModelName;
        var valueProviderResult = bindingContext.ValueProvider.GetValue(modelName);

        if (valueProviderResult == ValueProviderResult.None) return Task.CompletedTask;

        bindingContext.ModelState.SetModelValue(modelName, valueProviderResult);

        var value = valueProviderResult.FirstValue;

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

public class ToothIdentifierBinderProvider : IModelBinderProvider
{
    public IModelBinder GetBinder(ModelBinderProviderContext context)
    {
        if (context == null) throw new ArgumentNullException(nameof(context));

        return context.Metadata.ModelType == typeof(ToothIdentifier) ? new BinderTypeModelBinder(typeof(ToothIdentifierBinder)) : null;
    }
}
```
 - Swashbuckle
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
 - Summary med bra och dåliga grejer
   - (+) Centralized validation
   - (+) När vi ser ToothIdentifier så vet vi att den är giltig, type safety, typ
   - (+) Smäller i "API-ytan"
   - (+) Tydligare API-dokumentation
   - (-) Mycket kod
