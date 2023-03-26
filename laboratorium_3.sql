use Northwind;

-- 1. Podaj liczbę produktów o cenach mniejszych niż 10$ lub większych niż
-- 20$

select count(*) as number_of_products
from Products
where UnitPrice < 10 or UnitPrice > 20;

-- 2. Podaj maksymalną cenę produktu dla produktów o cenach poniżej 20$

select top 1 UnitPrice
from Products
where UnitPrice < 20
order by UnitPrice desc;

-- 3. Podaj maksymalną i minimalną i średnią cenę produktu dla produktów o
-- produktach sprzedawanych w butelkach (‘bottle’)

select min(UnitPrice) as min, max(UnitPrice) as max, avg(UnitPrice) as avg
from Products
where QuantityPerUnit like '%bottles%';

-- 4. Wypisz informację o wszystkich produktach o cenie powyżej średniej

select avg(UnitPrice) as avg
from Products;

select ProductID, ProductName, UnitPrice
from Products
where UnitPrice > (select avg(UnitPrice) as avg
from Products);


-- 5. Podaj sumę/wartość zamówienia o numerze 10250

select cast(sum(UnitPrice * Quantity * (1 - Discount)) as decimal(10,2)) as TotalPrice
from [Order Details]
where OrderID=10250
group by OrderID;

-- 2. Posortuj zamówienia wg maksymalnej ceny produktu

select OrderID, max(UnitPrice)
from [Order Details]
group by OrderID
order by max(UnitPrice) desc;

-- 3. Podaj maksymalną i minimalną cenę zamawianego produktu dla każdego
-- zamówienia

select OrderID, max(UnitPrice) as max, min(UnitPrice) as min
from [Order Details]
group by OrderID;

-- 4. Podaj liczbę zamówień dostarczanych przez poszczególnych spedytorów
-- (przewoźników)

select ShipVia, count(*) as number_of_orders
from Orders
group by ShipVia;

-- 5. Który z spedytorów był najaktywniejszy w 1997 roku

select TOP 1 ShipVia, count(*) as number_of_orders_in_1997
from Orders
where year(ShippedDate) = 1997
group by ShipVia
order by count(*) desc;

-- 1. Wyświetl zamówienia dla których liczba pozycji zamówienia jest większa niż 5

select OrderID, count(*) as number_of_positions
from [Order Details]
group by OrderID
having count(*) > 5;


-- 2. Wyświetl klientów dla których w 1998 roku zrealizowano więcej niż 8 zamówień
-- (wyniki posortuj malejąco wg łącznej kwoty za dostarczenie zamówień dla
-- każdego z klientów)

select CustomerID, count(*), sum(Freight) as sum_freight
from Orders
where year(ShippedDate) = 1998
group by CustomerID
having count(*) > 8
order by sum_freight desc;

-- 1. Napisz polecenie, które oblicza wartość sprzedaży dla każdego zamówienia
-- w tablicy order details i zwraca wynik posortowany w malejącej kolejności
-- (wg wartości sprzedaży).

select ProductID, (UnitPrice * Quantity) * (1 - Discount) as price
from [Order Details]
order by price desc;


-- 2. Zmodyfikuj zapytanie z poprzedniego punktu, tak aby zwracało pierwszych
-- 10 wierszy

select top 10 ProductID, (UnitPrice * Quantity) * (1 - Discount) as price
from [Order Details]
order by price desc;

-- 1. Podaj liczbę zamówionych jednostek produktów dla produktów, dla których
-- productid < 3

select ProductID, sum(Quantity) as number_of_products
from [Order Details]
where ProductID < 3
group by ProductID;

-- 2. Zmodyfikuj zapytanie z poprzedniego punktu, tak aby podawało liczbę
-- zamówionych jednostek produktu dla wszystkich produktów

select ProductID, sum(Quantity) as number_of_products
from [Order Details]
group by ProductID;

-- 3. Podaj nr zamówienia oraz wartość zamówienia, dla zamówień, dla których
-- łączna liczba zamawianych jednostek produktów jest > 250

select OrderID, SUM((UnitPrice * Quantity) * (1 - Discount)) as TotalPrice
from dbo.[Order Details]
group by OrderID
having SUM(Quantity) > 250;

------------------------------------------
--- except - operacja różnicy zbiorów  ---
------------------------------------------

-- 1. Dla każdego pracownika podaj liczbę obsługiwanych przez niego zamówień

select EmployeeID, count(*) as orders_number
from Orders
group by EmployeeID;

-- 2. Dla każdego spedytora/przewoźnika podaj wartość "opłata za przesyłkę"
-- przewożonych przez niego zamówień

select ShipVia, sum(Freight) as TotalFreights
from Orders
group by ShipVia;

-- 3. Dla każdego spedytora/przewoźnika podaj wartość "opłata za przesyłkę"
-- przewożonych przez niego zamówień w latach o 1996 do 1997

select ShipVia, sum(Freight) as TotalFreights
from Orders
where year(ShippedDate) in (1996, 1997)
group by ShipVia;

-- 1.Dla każdego pracownika podaj liczbę obsługiwanych przez niego zamówień z
-- podziałem na lata i miesiące

select EmployeeID, year(OrderDate) as year, month(OrderDate) as month, count(*)
from Orders
group by EmployeeID, year(OrderDate), month(OrderDate)
order by EmployeeID, year(OrderDate), month(OrderDate);

-- 2.Dla każdej kategorii podaj maksymalną i minimalną cenę produktu w tej
-- kategorii

select Products.CategoryID, CategoryName, min(UnitPrice) as min, max(UnitPrice) as max
from Products
inner join Categories
on Categories.CategoryID = Products.CategoryID
group by Products.CategoryID, Categoryname;

-- Który kilient najdłużej czkał na swoje zamównienie

select top 1 Orders.CustomerID, Customers.CompanyName, sum(datediff(minute, OrderDate, ShippedDate)) as time
from Orders
inner join Customers on Orders.CustomerID = Customers.CustomerID
group by Orders.CustomerID, Customers.CompanyName
order by time desc;
