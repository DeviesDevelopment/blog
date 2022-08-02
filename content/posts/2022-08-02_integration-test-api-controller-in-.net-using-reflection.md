---
title: "Integration Test Api in .Net Using Reflection"
date: 2022-08-02T09:07:50+02:00
tags: [".NET", "Test", "Api"]
featured_image: ""
description: ""
slug: "integration-test-api-controller-in-.net-using-reflection"
author:
 - Albin Bramstång
---
There are a few different approaches to testing in the spectrum between simple unit tests and complete E2E tests. If I had to choose one approach to prioritize I would pick integration tests.  

The key reasons are:
- Tests a flow of multiple functions, in contrast with unit tests where only a single function is tested
- Self contained i.e. the test has no external dependencies on a deployed environment etc. 
- Makes logical sense to test a complete function in a REST api, a single Lambda in AWS or an Azure function

## The problem
In my case the goal was to setup a test suite for a .NET web api. I quickly realized that the naive way to explicitly instantiate every controller plus all dependencies would lead
to lots of repeated boilerplate code in order to setup a test case. I also wanted to make use of the existing [DI](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection?view=aspnetcore-6.0) configuration.  
So how to create a generic setup where new test cases is a breeze to create? 🤔

## The solution
Reflection!

```csharp
public static class ControllerBuilder
{
    public static T GetController<T>()
    {
        var serviceProvider = new ServiceCollection()
            .AddServices()
            .SetupMock<T>()
            .BuildServiceProvider();

        var args = typeof(T)
            .GetConstructors(BindingFlags.Instance | BindingFlags.Public)
            .First()
            .GetParameters()
            .Select(p => serviceProvider.GetService(p.ParameterType))
            .ToArray();
        
        return (T)Activator.CreateInstance(typeof(T), args)!;
    }

    private static IServiceCollection SetupMock<T>(this IServiceCollection services)
    {
        services.Replace(new ServiceDescriptor(typeof(ILogger<T>), new Mock<ILogger<T>>().Object));
        return services;
    }
}

public static class ServiceConfiguration
{
    public static IServiceCollection AddServices(this IServiceCollection services)
    {
        services.AddScoped<IWeatherForecastService, WeatherForecastService>();
        return services;
    }
}
```

Instead of creating everything manually I built this. It takes the controller type, extracts all parameters from the public constructor, matches them with a real or mocked instance in 
the service collection and creates the controller instance for you. Simple as that! The two extension methods **SetupMock** and **AddServices** are convenient ways to
setup the real service configuration and the mocked one. The approach is to only mock what you need to mock and try to use as much real code as possible. 

A small test case will look like this. Very nice! 👍

```csharp
[Fact]
public void Get_Returns_Data()
{
    var controller = ControllerBuilder.GetController<WeatherForecastController>();
    var response = controller.Get().Result as OkObjectResult;
    var value = response?.Value as IEnumerable<WeatherForecast>;
    
    Assert.NotNull(value);
    Assert.NotEmpty(value);
}
```