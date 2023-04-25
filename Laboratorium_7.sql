-- 1)
-- Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14' zwróciły do biblioteki
-- książkę o tytule 'Walking'

use library;

select m.member_no, firstname, lastname
from loanhist as lh
inner join juvenile  as j on lh.member_no = j.member_no
inner join member as m on m.member_no = j.member_no
inner join title as t on lh.title_no = t.title_no
where t.title = 'Walking' and year(in_date) = 2001 and month(in_date) = 12 and day(in_date) = 14;

select member_no, firstname, lastname
from member
where member_no in (
    select member_no
    from juvenile
    where member_no in (
        select member_no
        from loanhist
        where year(in_date) = 2001 and month(in_date) = 12 and day(in_date) = 14
                    and title_no = (
            select title_no
            from title
            where title = 'Walking'
    )
        )
    );

-- 2)
-- Pokaż nazwy produktów, które nie by z kategorii 'Beverages' które nie były kupowane w
-- okresie od '1997.02.20' do '1997.02.25'. Dla każdego takiego produktu podaj jego nazwę,
-- nazwę dostawcy (supplier), oraz nazwę kategorii.
-- Zbiór wynikowy powinien zawierać nazwę produktu, nazwę dostawcy oraz nazwę kategorii.

use Northwind;

select P.ProductID, ProductName, P.SupplierID, CompanyName, CategoryName
from [Order Details] as OD
inner join Orders as O on O.OrderID = OD.OrderID and OrderDate between '1997-02-20' and '1997-02-25'
right join Products as P on OD.ProductID = P.ProductID
inner join Suppliers S on P.SupplierID = S.SupplierID
inner join Categories C on P.CategoryID = C.CategoryID
where OD.ProductID is null and CategoryName <> 'Beverages';

-- 3)
-- Podaj liczbę̨ zamówień oraz wartość zamówień (uwzględnij opłatę za przesyłkę) obsłużonych
-- przez każdego pracownika w lutym 1997. Za datę obsłużenia zamówienia należy uznać datę
-- jego złożenia (orderdate). Jeśli pracownik nie obsłużył w tym okresie żadnego zamówienia, to
-- też powinien pojawić się na liście (liczba obsłużonych zamówień oraz ich wartość jest w takim
-- przypadku równa 0).
-- Zbiór wynikowy powinien zawierać: imię i nazwisko pracownika, liczbę obsłużonych
-- zamówień, wartość obsłużonych zamówień

select E.EmployeeID, FirstName, LastName, count(Oid), cast( sum(value) as decimal (10, 2)) as value
from Employees as E
left join (
    select EmployeeID, O.OrderID as Oid, sum(UnitPrice * Quantity * (1 - Discount)) + O.Freight as value
    from Orders as O
    inner join [Order Details] as OD on O.OrderID = OD.OrderID and year(OrderDate) = 1997 and month(OrderDate) = 2
    group by EmployeeID, O.OrderID, O.Freight
) as T on T.EmployeeID = E.EmployeeID
group by E.EmployeeID, FirstName, LastName;

-- 1)
-- Podaj listę dzieci będących członkami biblioteki, dla każdego z tych dzieci podaj:
-- Imię, nazwisko, imię rodzica (opiekuna), nazwisko rodzica (opiekuna)

use library;

select jm.firstname as child_name, jm.lastname child_lastname, am.firstname as parent_name, am.lastname as parent_lastname
from juvenile as j
inner join member as jm on jm.member_no = j.member_no
inner join member as am on am.member_no = j.adult_member_no;


-- 2)
-- Wyświetl wszystkich pracowników, którzy nie mają podwładnych. Dla każdego z takich
-- pracowników podaj wartość obsłużonych przez niego zamówień w 1997r (sama wartość
-- zamówień bez opłaty za przesyłkę

use Northwind;

select E.EmployeeID, cast(sum(UnitPrice * Quantity * (1 - Discount)) as decimal (10, 2)) as total_value
from Employees as E
left join Orders O on E.EmployeeID = O.EmployeeID and year(OrderDate) = 1997
left join [Order Details] as OD on O.OrderID = OD.OrderID
where E.EmployeeID not in (
select ReportsTo
from Employees
where ReportsTo is not null
    )
group by E.EmployeeID;

-- 3)
-- Wyświetl nr zamówień złożonych w marcu 1997, które nie zawierały produktów z kategorii
-- "confections"

select O.OrderID
from [Order Details] as OD
inner join Products P on OD.ProductID = P.ProductID
inner join Categories C on P.CategoryID = C.CategoryID and CategoryName = 'Confections'
right join Orders O on OD.OrderID = O.OrderID
where OD.OrderID is null and year(OrderDate) = 1997 and month(OrderDate) = 3;

select OrderID
from Orders as O
where year(OrderDate) = 1997 and month(OrderDate) = 3
    and OrderID not in (
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
    );

-- Podaj listę wszystkich dorosłych, którzy mieszkają w Arizonie i mają dwójkę dzieci zapisanych do biblioteki
--     oraz listę dorosłych, mieszkających w Kalifornii  i mają 3 dzieci.
--     Dla każdej z tych osób podaj liczbę książek przeczytanych w grudniu 2001 przez tę osobę i jej dzieci.
--     (Arizona - 'AZ', Kalifornia - 'CA')

use library;

select a.member_no, firstname, lastname, (
    select count(*)
    from loanhist
    where member_no = a.member_no and year(in_date) = 2001 and month(in_date) = 12
    ) as adult_books_number, (select count(*)
        from loanhist as l
        inner join juvenile j2 on j2.member_no = l.member_no and j2.adult_member_no = a.member_no
        where year(in_date) = 2001 and month(in_date) = 12
        ) childeren_books_number
from adult as a
inner join member as m on m.member_no = a.member_no
inner join juvenile j on a.member_no = j.adult_member_no
group by a.member_no, firstname, lastname, state
having (
    (count(*) = 2 and state = 'AZ') or
    (count(*) = 3 and state = 'CA')
           );


-- 1 Imie nazwisko i adres czytelnika, ile książek wypożyczył aktualnie. Jesli żadnej to też ma sie pojawić

use library;

select m.member_no, state, city, street, count(isbn) as count
from member as m
inner join adult as a on a.member_no = m.member_no
left join loan l on m.member_no = l.member_no
where m.member_no is not null
group by m.member_no, state, city, street
union all
select j.member_no, state, city, street, count(isbn) as count
from juvenile as j
inner join adult a on a.member_no = j.adult_member_no
left join loan l on j.member_no = l.member_no
where j.member_no is not null
group by j.member_no, state, city, street;



-- 2 Liczba i ilość zamówień dla każdego klienta w lutym 1997. Jeśli nie składał, też ma być na liście

use Northwind;

select C.CustomerID, CompanyName, count(OrderID) as number_of_orders
from Customers C
left join Orders O on C.CustomerID = O.CustomerID and year(OrderDate) = 1997 and month(OrderDate) = 2
group by C.CustomerID, CompanyName;

-- 3. Klienci którzy nigdy nie zamówili produktu z kat. 'Seafood'

select C2.CustomerID, CompanyName
from Orders as O
inner join [Order Details] as OD on O.OrderID = OD.OrderID
inner join Products P on OD.ProductID = P.ProductID
inner join Categories C on P.CategoryID = C.CategoryID and CategoryName = 'Seafood'
right join Customers C2 on O.CustomerID = C2.CustomerID
where O.CustomerID is null;

select CustomerID, CompanyName
from Customers
where CustomerID not in (
    select CustomerID
    from Orders O
    inner join [Order Details] as OD on O.OrderID = OD.OrderID
    inner join Products P on OD.ProductID = P.ProductID
    inner join Categories C on P.CategoryID = C.CategoryID and CategoryName = 'Seafood'
    );

-- Imiona i nazwiska pracowników, którzy mają podwładnych i mają przełożonych

select distinct E.EmployeeID, E.FirstName, E.LastName
from Employees as E
left join Employees as E2 on E.EmployeeID = E2.ReportsTo
where E.ReportsTo is not null and E2.EmployeeID is not null;

select distinct E.EmployeeID, E.FirstName, E.LastName
from Employees as E
where E.ReportsTo is not null and E.EmployeeID in (
    select ReportsTo
    from Employees
    );

-- Dla każdego przewoźnika wświetl nazwy klientów, których zamówienia były opóźnione

select distinct ShipperID, S.CompanyName, C.CustomerID, C.CompanyName
from Shippers as S
left join Orders as O on S.ShipperID = O.ShipVia and ShippedDate > RequiredDate
left join Customers C on O.CustomerID = C.CustomerID;

-- Wyświetl listę dzieci, które mają przeterminowane zamówienia (imiona, nazwiska)

use library;

select distinct j.member_no, firstname, lastname
from member as m
inner join juvenile as j on j.member_no = m.member_no
inner join loan as l on l.member_no = j.member_no and due_date < getdate();


