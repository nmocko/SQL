use Northwind;

-- Dla każdego takiego produktu podaj jego nazwę, nazwę kategorii do której należy ten produkt oraz jego cenę.
-- Podaj nazwy produktów które w marcu 1997 nie były kupowane przez klientów z Francji.

select distinct P.ProductID, ProductName, P.UnitPrice, CategoryName
from [order details] as OD
inner join Orders as O  on O.OrderID = OD.OrderID and year(OrderDate) = 1997 and month(OrderDate) = 3
inner join Customers as C on O.CustomerID = C.CustomerID and Country = 'France'
right join Products P on OD.ProductID = P.ProductID
inner join Categories Ca on Ca.CategoryID = P.CategoryID
where OD.ProductID is null;

select distinct P.ProductID, ProductName, P.UnitPrice, CategoryName
from Products as P
inner join Categories C on C.CategoryID = P.CategoryID
where ProductID not in (
    select OD.ProductID
    from [order Details] as OD
    inner join Orders as O on O.OrderID = OD.OrderID and year(OrderDate) = 1997 and month(OrderDate) = 3
    inner join Customers C on O.CustomerID = C.CustomerID and Country = ('France')
    );

-- podaj nazwy klientów którzy w marcu 1997 nie skladali zamówień

select C.CustomerID, CompanyName
from Customers C
left join Orders O on C.CustomerID = O.CustomerID and year(OrderDate) = 1997 and month(OrderDate) = 3
where O.CustomerID is null;

select CustomerID, CompanyName
from Customers
where CustomerID not in (
    select CustomerID
    from Orders
    where year(OrderDate) = 1997 and month(OrderDate) = 3
    );

-- podaj nazwy klientów ktorym w marcu 1997 przesyłek nie przewoziła firma united package

-- !!!!!!!!!!!!!!!!!!!


select distinct C.CustomerID, C.CompanyName
from Customers C
left join Orders O on C.CustomerID = O.CustomerID and year(ShippedDate) = 1997 and month(ShippedDate) = 3
                                 and ShipVia in (select ShipperID from Shippers where CompanyName = 'United Package')
where O.CustomerID is null;


select CustomerID, CompanyName
from Customers
where CustomerID not in (
    select CustomerID
    from orders
    inner join Shippers S on Orders.ShipVia = S.ShipperID and S.CompanyName = 'United Package'
    where year(ShippedDate) = 1997 and month(ShippedDate) = 3
    );

-- podaj nawy klientów którzy w marcu 1997 nie kupowali produków z kategorii confections

select distinct C.CustomerID, C.CompanyName
from Products as P
inner join Categories as CC on P.CategoryID = CC.CategoryID and CategoryName = 'Confections'
inner join [Order Details] as OD on P.ProductID = OD.ProductID
inner join Orders as O on OD.OrderID = O.OrderID and year(O.OrderDate) = 1997 and month(O.OrderDate) = 3
right join Customers as C on O.CustomerID = C.CustomerID
where O.CustomerID is null;

select CustomerID, CompanyName
from Customers
where CustomerID not in (
    select CustomerID
    from Orders O
    left join [Order Details] OD on O.OrderID = OD.OrderID
    left join Products P on OD.ProductID = P.ProductID
    inner join Categories C on P.CategoryID = C.CategoryID and C.CategoryName = 'Confections'
    where month(OrderDate) = 3 and year(OrderDate) = 1997
    );

-- Wyświetl nazwy produktów, kupionych między '1997-02-01' i '1997-05-01' przez co najmniej 6 różnych klientów

select T.ProductID, T.ProductName
from (
    select distinct P.ProductID, ProductName, CustomerID
    from Products as P
    inner join [Order Details] as OD on P.ProductID = OD.ProductID
    inner join Orders O on OD.OrderID = O.OrderID and OrderDate between '1997-02-01' and '1997-05-01'
    ) as T
group by ProductID, ProductName
having count(*) >= 6;

use library;

-- Dla każdego dorosłego czytelnika podaj sumę kar zapłaconych za
-- przetrzymywanie książek przez jego dzieci
-- interesują nas czytelnicy którzy mają dzieci

select m.member_no, firstname, lastname, sum(fine_paid) as sum_fine_paid
from member as m
inner join juvenile as j on j.adult_member_no = m.member_no
left join loanhist as lh on j.member_no = lh.member_no
group by m.member_no, firstname, lastname;
-- having sum(fine_paid) is not null;

select member.member_no, (
    select sum(fine_paid)
    from loanhist as lh
    where lh.member_no in (
        select member_no
        from juvenile as ju
        where ju.adult_member_no = member.member_no
        )
    ) as sum
from member
where member_no in (
    select adult_member_no
    from juvenile
    );

-- and (
--     select sum(fine_paid)
--     from loanhist as lh
--     where lh.member_no in (
--         select member_no
--         from juvenile as ju
--         where ju.adult_member_no = member.member_no
--         )
--     ) is not null;


-- Podaj wartość produktów sprzedanych w latach 1995-1999

with rec as
(
select 1995 as x
union all
select x+1 from rec where x<1999
)
select rec.x as year, cast(sum(UnitPrice * OD.ProductID * (1 - OD.Discount)) as decimal (10, 2))
from [Order Details] as OD
inner join Orders as O on OD.OrderID = O.OrderID
right join rec on rec.x = year(OrderDate)
group by rec.x;


