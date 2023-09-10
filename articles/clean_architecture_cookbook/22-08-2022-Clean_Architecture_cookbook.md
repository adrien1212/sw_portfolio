---
title: Clean Architecture Cookbook
date: 22/08/2022
author: Adrien CAUBEL
---

# References
This article isn't a course about the Clean Architecture. It is intended for people who have already understood the concept of Clean Architecture and want to implement it.  

- The book *Clean Architecture: A Craftsman's Guide to Software Structure and Design*.
- The book *Get Your Hands Dirty on Clean Architecture* teach you how to build the Clean Architecture.

# Diagram
In the following section we learn how to implement this diagram in Java.

![](images/clean-architecture-design.png)

# The Core
The first step is to build the core of the application.
![](images/core.png)

## Entity
```java
public class Car {
   private String model;
   private String brand;
}
```

```java
public class Client {
   private String firstName;
   private String lastName;
   private Lisr<Car> cars;
}
```

## CarRequestModel


## Service interface (Boundary)
```java
public interface BuyCarUseCase {
    boolean buyCar(CarRequestModel car)    
}
```

## Service implementation (Interactor)


# The Web

# The database