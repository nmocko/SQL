select * from Products
where SupplierID=4;

select * from Suppliers;

select * from Categories;

select * from Customers;

select * from Orders;

select * from [Order Details]
         where orderid = 10250;

select ReportsTo, * from Employees;

select EmployeeID, lastname, FirstName, title
from Employees
where EmployeeID >= 5;

-- ćwiczenia 1

-- 1. Wybierz nazwy i adresy wszystkich klientów
select  ContactName, Address, City, Region, PostalCode, Country from Customers;
-- 2. Wybierz nazwiska i numery telefonów pracowników
select LastName, HomePhone from Employees;
-- 3. Wybierz nazwy i ceny produktów
select ProductName, UnitPrice from Products;
-- 4. Pokaż wszystkie kategorie produktów (nazwy i opisy)
select CategoryName, Description from Categories;
-- 5. Pokaż nazwy i adresy stron www dostawców
select CompanyName, HomePage from Suppliers;
-- select * from Suppliers;

-- ćwiczenia 2

-- 1. Wybierz nazwy i adresy wszystkich klientów mających siedziby w Londynie
select CompanyName, Address, City, Region, PostalCode, Country from Customers where City = 'London';
-- 2. Wybierz nazwy i adresy wszystkich klientów mających siedziby we Francji lub w
-- Hiszpanii
select CompanyName, Address from Customers where Country = 'France' or Country = 'Spain';
-- 3. Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00
select ProductName, UnitPrice from Products where UnitPrice between 20 and 30;
-- 4. Wybierz nazwy i ceny produktów z kategorii ‘meat’
select Products.ProductName, Products.UnitPrice
from Products
    inner join Categories
        on Categories.CategoryID = Products.CategoryID
where Categories.CategoryName = 'Meat/Poultry';
select ProductName, UnitPrice from Products
        where CategoryID = (select CategoryID from Categories where CategoryName LIKE '%Meat%');
select CategoryID from dbo.Categories where CategoryName LIKE '%Meat%';
select ProductName, UnitPrice from Products where CategoryID = 6;
-- 5. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów
-- dostarczanych przez firmę ‘Tokyo Traders’
select ProductName, UnitsInStock from Products where SupplierID in (select SupplierID from dbo.Suppliers
                                where CompanyName = 'Tokyo Traders');
declare @id int;
set @id = (select SupplierID from Suppliers where CompanyName = 'Tokyo Traders')
select ProductName, UnitsInStock from Products where SupplierID = @id;
-- 6. Wybierz nazwy produktów których nie ma w magazynie
select ProductName from Products where UnitsInStock = 0;
