-- Podzapytania

use Northwind;

-- Ćwiczenie 1

-- 1.Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki
-- dostarczała firma United Package.

select CustomerID, CompanyName, Phone
from Customers
where CustomerID in (
    select CustomerID
    from Orders
    where ShipVia in (
        select ShipperID
        from Shippers
        where CompanyName = 'United Package'
        ) and year(ShippedDate) = '1997'
    );

-- 2.Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii
-- Confections.

select CustomerID, CompanyName, Phone
from Customers as C
where exists (
    select OrderID
    from Orders as O
    where OrderID in (
        select OrderID
        from [Order Details]
        where ProductID in (
            select ProductID
            from Products
            where CategoryID in (
                select CategoryID
                from Categories
                where CategoryName = 'Confections'
                )
            )
        ) and C.CustomerID = O.CustomerID
          );

-- 3.Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z
-- kategorii Confections.

select CustomerID, CompanyName, Phone
from Customers as C
where not exists (
    select OrderID
    from Orders as O
    where OrderID in (
        select OrderID
        from [Order Details]
        where ProductID in (
            select ProductID
            from Products
            where CategoryID in (
                select CategoryID
                from Categories
                where CategoryName = 'Confections'
                )
            )
        ) and C.CustomerID = O.CustomerID
          );



-- Ćwiczenie 2

-- 1.Dla każdego produktu podaj maksymalną liczbę zamówionych jednostek

select ProductID, ProductName,
                   (select max(Quantity)
                    from dbo.[Order Details] as OD
                    where OD.ProductID = P.ProductID)
from Products as P;

-- 2.Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu

select ProductID, ProductName
from Products
where UnitPrice < (select avg(UnitPrice)
                   from Products);

-- 3.Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu
-- danej kategorii

select ProductID, ProductName
from Products as P
where UnitPrice < (
    select avg(UnitPrice)
    from Products as P2
    where P.CategoryID = P2.CategoryID
    );

-- Ćwiczenie 3

-- 1.Dla każdego produktu podaj jego nazwę, cenę, średnią cenę wszystkich
-- produktów oraz różnicę między ceną produktu a średnią ceną wszystkich
-- produktów

select ProductID, ProductName, cast(UnitPrice as decimal (10, 2)),
       cast((select avg(UnitPrice) from Products) as decimal (10, 2)),
       cast(UnitPrice - (select avg(UnitPrice) from Products) as decimal (10, 2))
from Products;

-- 2.Dla każdego produktu podaj jego nazwę kategorii, nazwę produktu, cenę, średnią
-- cenę wszystkich produktów danej kategorii oraz różnicę między ceną produktu a
-- średnią ceną wszystkich produktów danej kategorii

select ProductID, (select CategoryName from Categories as C where P.CategoryID = C.CategoryID) as CategoryName,
       ProductName,
       (select avg(UnitPrice) from Products as P2 where P.CategoryID = P2.CategoryID) as AvgForCategory,
        UnitPrice - (select avg(UnitPrice) from Products as P2 where P.CategoryID = P2.CategoryID) as Diference
from Products as P;

-- Ćwiczenie 4

-- 1.Podaj łączną wartość zamówienia o numerze 1025 (uwzględnij cenę za przesyłkę)

select OrderID, cast(Freight + (select sum(Quantity*UnitPrice * (1-Discount)) from [Order Details] as OD
                        where OrderID = 10250) as decimal (10, 2)) as sum
from Orders
where OrderID = 10250;


-- 2.Podaj łączną wartość zamówień każdego zamówienia (uwzględnij cenę za
-- przesyłkę)

select OrderID, cast(Freight + (select sum(Quantity*UnitPrice * (1-Discount)) from [Order Details] as OD
                        where O.OrderID = OD.OrderID) as decimal (10, 2)) as sum
from Orders as O;

-- 3.Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak
-- to pokaż ich dane adresowe

select CustomerID, CompanyName, Country, PostalCode, Region, City, Address
from Customers as C
where not exists (
    select *
    from Orders as O
    where O.CustomerID = C.CustomerID
    and year(OrderDate) = '1997'
    );

-- 4.Podaj produkty kupowane przez więcej niż jednego klienta

select distinct ProductID
from [Order Details] as OD
where ProductID in (
    select ProductID
    from Orders as O
    where CustomerID in (
        select CustomerID
        from Orders as O2
        group by CustomerID
        having count(*) > 1
        )
    );

-- Ćwiczenie 5

-- 1.Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika (przy obliczaniu wartości zamówień
-- uwzględnij cenę za przesyłkę

select EmployeeID, FirstName, LastName,
       cast((select sum(Freight) from Orders as O
                            where O.EmployeeID = E.EmployeeID) +
       (select sum(Quantity * UnitPrice * (1-Discount)) from [Order Details] as OD
                            where OrderID in (
                                select OrderID
                                from Orders as O
                                where O.EmployeeID = E.EmployeeID
                                )) as decimal (10, 2)) as TotalSum
from Employees as E;

-- 2.Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia o
-- największej wartości) w 1997r, podaj imię i nazwisko takiego pracownika

select top 1 FirstName, LastName,
       cast((select sum(Freight) from Orders as O
                            where O.EmployeeID = E.EmployeeID) +
       (select sum(Quantity * UnitPrice * (1-Discount)) from [Order Details] as OD
                            where OrderID in (
                                select OrderID
                                from Orders as O
                                where O.EmployeeID = E.EmployeeID
                                and year(OrderDate) = '1997'
                                )) as decimal (10, 2)) as TotalSum
from Employees as E
order by TotalSum;

-- 3.Ogranicz wynik z pkt 1 tylko do pracowników
-- a) którzy mają podwładnych

select FirstName, LastName,
       cast((select sum(Freight) from Orders as O
                            where O.EmployeeID = E.EmployeeID) +
       (select sum(Quantity * UnitPrice * (1-Discount)) from [Order Details] as OD
                            where OrderID in (
                                select OrderID
                                from Orders as O
                                where O.EmployeeID = E.EmployeeID
                                )) as decimal (10, 2)) as TotalSum
from Employees as E
where EmployeeID in (
        select ReportsTo
        from Employees
        where ReportsTo is not null
          );

-- b) którzy nie mają podwładnych

select FirstName, LastName,
       cast((select sum(Freight) from Orders as O
                            where O.EmployeeID = E.EmployeeID) +
       (select sum(Quantity * UnitPrice * (1-Discount)) from [Order Details] as OD
                            where OrderID in (
                                select OrderID
                                from Orders as O
                                where O.EmployeeID = E.EmployeeID
                                )) as decimal (10, 2)) as TotalSum
from Employees as E
where EmployeeID not in (
        select E2.ReportsTo
        from Employees as E2
        where E2.ReportsTo is not null
          );

-- 4.Zmodyfikuj rozwiązania z pkt 3 tak aby dla pracowników pokazać jeszcze datę
-- ostatnio obsłużonego zamówienia

-- a) którzy mają podwładnych

select FirstName, LastName,
       cast((select sum(Freight) from Orders as O
                            where O.EmployeeID = E.EmployeeID) +
       (select sum(Quantity * UnitPrice * (1-Discount)) from [Order Details] as OD
                            where OrderID in (
                                select OrderID
                                from Orders as O
                                where O.EmployeeID = E.EmployeeID
                                )) as decimal (10, 2)) as TotalSum,
    (select max(OrderDate) from Orders as O
                           where O.EmployeeID = E.EmployeeID) as LastOrder
from Employees as E
where EmployeeID in (
        select ReportsTo
        from Employees
        where ReportsTo is not null
          );

-- b) którzy nie mają podwładnych

select FirstName, LastName,
       cast((select sum(Freight) from Orders as O
                            where O.EmployeeID = E.EmployeeID) +
       (select sum(Quantity * UnitPrice * (1-Discount)) from [Order Details] as OD
                            where OrderID in (
                                select OrderID
                                from Orders as O
                                where O.EmployeeID = E.EmployeeID
                                )) as decimal (10, 2)) as TotalSum,
        (select max(OrderDate) from Orders as O
                           where O.EmployeeID = E.EmployeeID) as LastOrder
from Employees as E
where EmployeeID not in (
        select E2.ReportsTo
        from Employees as E2
        where E2.ReportsTo is not null
          );
