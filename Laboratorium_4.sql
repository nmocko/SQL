use Northwind;


-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej
-- pomiędzy 20.00 a 30.00, dla każdego produktu podaj dane adresowe dostawcy

select ProductName, UnitPrice, Country, PostalCode, Region, City, Address
from Products inner join Suppliers S
    on Products.SupplierID = S.SupplierID
where UnitPrice between 20 and 30;

-- 2. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów
-- dostarczanych przez firmę ‘Tokyo Traders’

select ProductName, UnitsInStock
from Products inner join Suppliers S
    on Products.SupplierID = S.SupplierID
where CompanyName = 'Tokyo Traders';

-- 3. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak
-- to pokaż ich dane adresowe

select distinct CustomerID, PostalCode, Region, City, Address
from Customers
where CustomerID not in(
select distinct C.CustomerID
from Customers C left join Orders O
    on C.CustomerID = O.CustomerID
where year(OrderDate) = '1997');

select distinct CustomerID, PostalCode, Region, City, Address
from Customers
where CustomerID not in(
select distinct CustomerID
from Orders
where year(OrderDate) = '1997');

select distinct C.CustomerID, PostalCode, Region, City, Address
from Customers C
left join Orders O
on C.CustomerID = O.CustomerID and year(orderdate) = '1997'
where O.CustomerID is null;






-- 4. Wybierz nazwy i numery telefonów dostawców, dostarczających produkty,
-- których aktualnie nie ma w magazynie

select CompanyName, Phone
from dbo.Suppliers as S inner join Products P
    on S.SupplierID = P.SupplierID
where UnitsInStock = 0;


use library;


-- 1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko i data urodzenia dziecka.

select firstname, lastname, birth_date
    from juvenile as j inner join member as m
    on j.member_no = m.member_no;


-- 2. Napisz polecenie, które podaje tytuły aktualnie wypożyczonych książek

select distinct title
    from loan as l inner join title as t
on l.title_no = t.title_no;

-- 3. Podaj informacje o karach zapłaconych za przetrzymywanie książki o tytule ‘Tao
-- Teh King’. Interesuje nas data oddania książki, ile dni była przetrzymywana i jaką
-- zapłacono karę

select in_date, datediff(day, in_date, due_date) as 'more_days', fine_paid
    from loanhist as l inner join title as t
on l.title_no = t.title_no
where title = 'Tao Teh King' and datediff(day, in_date, due_date) > 0;

-- 4. Napisz polecenie które podaje listę książek (mumery ISBN) zarezerwowanych
-- przez osobę o nazwisku: Stephen A. Graff

select isbn
    from reservation as r inner join member m
        on r.member_no = m.member_no
    where firstname = 'Stephen' and middleinitial = 'A' and lastname = 'Graff';


use Northwind;


-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej
-- pomiędzy 20.00 a 30.00, dla każdego produktu podaj dane adresowe dostawcy,
-- interesują nas tylko produkty z kategorii ‘Meat/Poultry’

select ProductName, UnitPrice, CompanyName, Country, PostalCode, Region, City, Address
    from Products P inner join Suppliers S
        on P.SupplierID = S.SupplierID
    inner join Categories C
        on P.CategoryID = C.CategoryID
where (UnitPrice between 20 and 30)
    and CategoryName = 'Meat/Poultry';


-- 2. Wybierz nazwy i ceny produktów z kategorii ‘Confections’ dla każdego produktu
-- podaj nazwę dostawcy.

select ProductName, UnitPrice, CompanyName
    from Products P inner join Suppliers S
        on P.SupplierID = S.SupplierID
    inner join Categories C
        on P.CategoryID = C.CategoryID
where CategoryName = 'Confections';

-- 3. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki
-- dostarczała firma ‘United Package’

select C.CompanyName, C.Phone, S.CompanyName
    from Customers C inner join Orders O
    on C.CustomerID = O.CustomerID inner join Shippers S
        on O.ShipVia = S.ShipperID
    where S.CompanyName = 'United Package' and year(O.ShippedDate) = '1997';


-- 4. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii
-- ‘Confections’

select distinct C.CompanyName, C.Phone
    from [Order Details] OD inner join Orders O
    on O.OrderID = OD.OrderID inner join Customers C
    on O.CustomerID = C.CustomerID inner join Products P
    on P.ProductID = OD.ProductID inner join Categories C2
        on P.CategoryID = C2.CategoryID
    where CategoryName = 'Confections';

-- Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produków z kategorii ‘Confections’

SELECT Customers.CompanyName, Customers.Phone
FROM Customers
    LEFT OUTER JOIN Orders O on Customers.CustomerID = O.CustomerID
    LEFT OUTER JOIN [Order Details] "[O D]" on O.OrderID = "[O D]".OrderID
    LEFT OUTER JOIN Products P on P.ProductID = "[O D]".ProductID
    LEFT OUTER JOIN Categories C on C.CategoryID = P.CategoryID AND (C.CategoryName = 'Confections')
        GROUP BY Customers.CustomerID, Customers.CompanyName, Customers.Phone
        HAVING COUNT(C.CategoryID) = 0;

select CompanyName, Phone
from Customers C
where C.CustomerID not in (select CustomerID
from Orders O
inner join [Order Details] [O D] on O.OrderID = [O D].OrderID
inner join Products P on P.ProductID = [O D].ProductID
inner join Categories C2 on C2.CategoryID = P.CategoryID
where C2.CategoryName = 'Confections');


--  Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z kategorii ‘Confections’

select distinct C.CompanyName, C.Phone
    from Orders O
    inner join [Order Details] OD on O.OrderID = OD.OrderID
    inner join Products P on OD.ProductID = P.ProductID
    inner join Categories CC on P.CategoryID = CC.CategoryID and CC.CategoryName = 'Confections'
    right join Customers C on O.CustomerID = C.CustomerID
    where O.CustomerID is null;

select * from dbo.Customers;

-- Wybierz nazwy i numery telefonów klientów, którzy w 1997 kupowali produkty z kategorii ‘Confections’

select distinct C.CompanyName, C.Phone
    from [Order Details] OD inner join Orders O
    on O.OrderID = OD.OrderID inner join Customers C
    on O.CustomerID = C.CustomerID inner join Products P
    on P.ProductID = OD.ProductID inner join Categories C2
        on P.CategoryID = C2.CategoryID
    where CategoryName = 'Confections' and year(O.OrderDate) = '1997';

--  Wybierz nazwy i numery telefonów klientów, którzy w 1997 nie kupowali produktów z kategorii ‘Confections’

select distinct C.CompanyName, C.Phone
    from Orders O
    inner join [Order Details] OD on O.OrderID = OD.OrderID and year(OrderDate) = '1997'
    inner join Products P on OD.ProductID = P.ProductID
    inner join Categories CC on P.CategoryID = CC.CategoryID and CC.CategoryName = 'Confections'
    right join Customers C on O.CustomerID = C.CustomerID
    where O.CustomerID is null;

use library;


-- 1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko, data urodzenia dziecka i adres
-- zamieszkania dziecka.

select firstname, lastname, birth_date, state, city, street
    from juvenile as j inner join member as m
    on j.member_no = m.member_no inner join adult a
    on a.member_no = j.adult_member_no;



-- 2. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko, data urodzenia dziecka, adres
-- zamieszkania dziecka oraz imię i nazwisko rodzica.

select tab.firstname, tab.lastname, birth_date, state, city, street, m.firstname, m.lastname
    from (select firstname, lastname, birth_date, state, city, street, adult_member_no
    from juvenile as j inner join member as m
    on j.member_no = m.member_no inner join adult a
    on a.member_no = j.adult_member_no) as tab
    inner join member as m
    on tab.adult_member_no = member_no;



use Northwind;

-- 1. Napisz polecenie, które wyświetla pracowników oraz ich podwładnych (baza
-- northwind)

select E.FirstName, E.LastName, Ep.FirstName, Ep.LastName
    from Employees as E left outer join Employees as Ep
        on E.EmployeeID = Ep.ReportsTo;

select ReportsTo, * from dbo.Employees;


-- 2. Napisz polecenie, które wyświetla pracowników, którzy nie mają podwładnych
-- (baza northwind)

select E.FirstName, E.LastName
    from Employees as E left outer join Employees as Ep
        on E.EmployeeID = Ep.ReportsTo
    where Ep.EmployeeID is null;

use library;

-- 3. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci
-- urodzone przed 1 stycznia 1996

select state, city, street
from adult a inner join juvenile j
on j.adult_member_no = a.member_no
where birth_date < '01-01-1996';

-- 4. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci
-- urodzone przed 1 stycznia 1996. Interesują nas tylko adresy takich członków
-- biblioteki, którzy aktualnie nie przetrzymują książek.

select distinct state, city, street, a.member_no
from adult a
    inner join juvenile j on j.adult_member_no = a.member_no
    left outer join loan l on a.member_no = l.member_no
where birth_date < '01-01-1996' and l.member_no is null;

-- 1. Napisz polecenie które zwraca imię i nazwisko (jako pojedynczą kolumnę –
-- name), oraz informacje o adresie: ulica, miasto, stan kod (jako pojedynczą
-- kolumnę – address) dla wszystkich dorosłych członków biblioteki

select concat(firstname, ' ', lastname) as 'name',
       concat(state, ' ', city, ' ', street) as address
from member
inner join adult a on member.member_no = a.member_no;

-- 2. Napisz polecenie, które zwraca: isbn, copy_no, on_loan, title, translation, cover,
-- dla książek o isbn 1, 500 i 1000. Wynik posortuj wg ISBN

select i.isbn, copy_no, on_loan, title, translation, cover
from item i
inner join copy c on i.isbn = c.isbn
inner join title t on i.title_no = t.title_no
where i.isbn in (1, 500, 1000)
order by i.isbn;

-- 3. Napisz polecenie które zwraca o użytkownikach biblioteki o nr 250, 342, i 1675
-- (dla każdego użytkownika: nr, imię i nazwisko członka biblioteki), oraz informację
-- o zarezerwowanych książkach (isbn, data)

select member.member_no, firstname, lastname, isbn, log_date
from member
inner join reservation r2 on member.member_no = r2.member_no
where member.member_no in (250, 342, 1675);

-- 4. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) mają więcej niż
-- dwoje dzieci zapisanych do biblioteki

select a.member_no, firstname, lastname
from adult a
inner join member m on m.member_no = a.member_no
inner join juvenile j on a.member_no = j.adult_member_no
where a.state = 'AZ'
group by a.member_no, firstname, lastname
having count(*) > 2;

-- 1. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) którzy mają więcej
-- niż dwoje dzieci zapisanych do biblioteki oraz takich którzy mieszkają w Kaliforni
-- (CA) i mają więcej niż troje dzieci zapisanych do biblioteki

select a.state, a.member_no, firstname, lastname
from adult a
inner join member m on m.member_no = a.member_no
inner join juvenile j on a.member_no = j.adult_member_no
group by a.member_no, firstname, lastname, a.state
having (a.state = 'AZ' and count(*) > 2)
    or (a.state = 'CA' and count(*) > 3);


use Northwind;

-- 1. Dla każdego zamówienia podaj łączną liczbę zamówionych jednostek towaru oraz
-- nazwę klienta.

select O.OrderID, CompanyName, FirstName, LastName, sum(Quantity) as 'sum_quantity'
    from Orders as O
    inner join [Order Details] as Od on Od.OrderID = O.OrderID
    inner join Customers as C on O.CustomerID = C.CustomerID
    inner join Employees E on O.EmployeeID = E.EmployeeID
    group by O.OrderID, CompanyName, FirstName, LastName;

-- 2. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których
-- łączna liczbę zamówionych jednostek jest większa niż 250

select O.OrderID, CompanyName, sum(Quantity) as 'sum_quantity'
    from Orders as O inner join [Order Details] as Od
        on Od.OrderID = O.OrderID
    inner join Customers as C
        on O.CustomerID = C.CustomerID
    group by O.OrderID, CompanyName
    having sum(Quantity) > 250;

-- 3. Dla każdego zamówienia podaj łączną wartość tego zamówienia oraz nazwę
-- klienta.

select O.OrderID, CompanyName, cast(sum(Quantity*UnitPrice*(1-Discount)) as decimal (10, 2)) as 'sum_value'
    from Orders as O inner join [Order Details] as Od
        on Od.OrderID = O.OrderID
    inner join Customers as C
        on O.CustomerID = C.CustomerID
    group by O.OrderID, CompanyName;

-- 4. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których
-- łączna liczba jednostek jest większa niż 250.

select O.OrderID, CompanyName, cast(sum(Quantity*UnitPrice*(1-Discount)) as decimal (10, 2)) as 'sum_value'
    from Orders as O inner join [Order Details] as Od
        on Od.OrderID = O.OrderID
    inner join Customers as C
        on O.CustomerID = C.CustomerID
    group by O.OrderID, CompanyName
    having sum(Quantity) > 250;

-- 5. Zmodyfikuj poprzedni przykład tak żeby dodać jeszcze imię i nazwisko
-- pracownika obsługującego zamówienie

select O.OrderID, C.CompanyName, cast(sum(Quantity*UnitPrice*(1-Discount)) as decimal (10, 2)) as 'sum_value',
        FirstName, LastName
    from Orders as O inner join [Order Details] as Od
        on Od.OrderID = O.OrderID
    inner join Customers as C
        on O.CustomerID = C.CustomerID
    inner join Employees E
        on O.EmployeeID = E.EmployeeID
    group by O.OrderID, C.CompanyName, FirstName, LastName
    having sum(Quantity) > 250;


-- 1. Dla każdej kategorii produktu (nazwa), podaj łączną liczbę zamówionych przez
-- klientów jednostek towarów z tej kategorii.

select C.CategoryName, sum(Quantity) as sum
from [Order Details]
inner join Products P
    on [Order Details].ProductID = P.ProductID
inner join Categories C
    on P.CategoryID = C.CategoryID
group by C.CategoryID, C.CategoryName;

-- 2. Dla każdej kategorii produktu (nazwa), podaj łączną wartość zamówionych przez
-- klientów jednostek towarów z tek kategorii.

select C.CategoryName, cast( sum(Quantity* P.UnitPrice * (1 - Discount)) as decimal (10, 2))
from [Order Details]
inner join Products P
    on [Order Details].ProductID = P.ProductID
inner join Categories C
    on P.CategoryID = C.CategoryID
group by C.CategoryID, C.CategoryName;

-- 3. Posortuj wyniki w zapytaniu z poprzedniego punktu wg:
-- a) łącznej wartości zamówień
-- b) łącznej liczby zamówionych przez klientów jednostek towarów.

select C.CategoryName, cast( sum(Quantity* P.UnitPrice * (1 - Discount)) as decimal (10, 2))
    as TotalValue
from [Order Details]
inner join Products P
    on [Order Details].ProductID = P.ProductID
inner join Categories C
    on P.CategoryID = C.CategoryID
group by C.CategoryID, C.CategoryName
order by TotalValue;

select C.CategoryName, sum(Quantity)
from [Order Details]
inner join Products P
    on [Order Details].ProductID = P.ProductID
inner join Categories C
    on P.CategoryID = C.CategoryID
group by C.CategoryID, C.CategoryName
order by sum(Quantity);


-- 4. Dla każdego zamówienia podaj jego wartość uwzględniając opłatę za przesyłkę

select OD.OrderID, cast(sum(UnitPrice * Quantity * (1 - Discount)) + Freight as decimal (10, 2))
    as TotalValue
from [Order Details] OD
inner join Orders O
    on OD.OrderID = O.OrderID
group by OD.OrderID, Freight;

select sum(UnitPrice* Quantity * (1 - Discount) )
from [Order Details]
where OrderID = 10250
group by OrderID;

select Freight
from dbo.Orders
where OrderID =10250;

-- 1.Dla każdego przewoźnika (nazwa) podaj liczbę zamówień które przewieźli w 1997r

select CompanyName, count(OrderID) as number_of_orders
from Shippers as S
left join Orders O on S.ShipperID = O.ShipVia
and year(ShippedDate) = '1997'
group by ShipperID, CompanyName;

-- 2.Który z przewoźników był najaktywniejszy (przewiózł największą liczbę
-- zamówień) w 1997r, podaj nazwę tego przewoźnika

select top 1 with ties CompanyName, count(*) as number_of_orders
from Shippers as S
inner join Orders O
    on S.ShipperID = O.ShipVia
where year(ShippedDate) = '1997'
group by ShipperID, CompanyName
order by number_of_orders desc;

-- 3.Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika

select FirstName, LastName , cast(sum(UnitPrice * Quantity * (1 -Discount)) as decimal (10, 2))
    as TotalValue
from Employees as E
inner join Orders as O
    on E.EmployeeID = O.EmployeeID
inner join [Order Details] as OD
    on OD.OrderID = O.OrderID
group by E.EmployeeID, FirstName, LastName;

-- 4.Który z pracowników obsłużył największą liczbę zamówień w 1997r, podaj imię i
-- nazwisko takiego pracownika

select top 1 with ties FirstName, LastName, count(*) as number_of_orders
from Employees as E
inner join Orders as O
    on E.EmployeeID = O.EmployeeID
where year(OrderDate) = '1997'
group by E.EmployeeID, FirstName, LastName
order by number_of_orders;

-- 5.Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia o
-- największej wartości) w 1997r, podaj imię i nazwisko takiego pracownika

select top 1 with ties FirstName, LastName, cast(sum(UnitPrice * Quantity * (1 -Discount)) as decimal (10, 2))
    as TotalValue
from Employees as E
inner join Orders as O
    on E.EmployeeID = O.EmployeeID
inner join [Order Details] as OD
    on OD.OrderID = O.OrderID
where year(OrderDate) = '1997'
group by E.EmployeeID, FirstName, LastName
order by TotalValue;

-- 1. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika
-- – Ogranicz wynik tylko do pracowników
-- a) którzy mają podwładnych
-- b) którzy nie mają podwładnych

-- a

select distinct E.FirstName, E.LastName, cast(sum(UnitPrice * Quantity * (1 -Discount)) as decimal (10, 2))
    as TotalValue
from Employees as E
left outer join Employees as E2
    on E2.ReportsTo = E.EmployeeID
inner join Orders as O
    on E.EmployeeID = O.EmployeeID
inner join [Order Details] as OD
    on OD.OrderID = O.OrderID
where E2.EmployeeID is not null
group by E.EmployeeID, E.FirstName, E.LastName, E2.EmployeeID;

-- b

select E.FirstName, E.LastName, cast(sum(UnitPrice * Quantity * (1 -Discount)) as decimal (10, 2))
    as TotalValue
from Employees as E
left outer join Employees as E2
    on E2.ReportsTo = E.EmployeeID
inner join Orders as O
    on E.EmployeeID = O.EmployeeID
inner join [Order Details] as OD
    on OD.OrderID = O.OrderID
where E2.EmployeeID is null
group by E.EmployeeID, E.FirstName, E.LastName;




-- Dla każdego kliena podaj w ilu różnych miesiącach (latach i miesiącah) robił zakupy w 1997r

select C.CustomerID, CompanyName,  count(O.OrderID) as number_of_orders
from Customers C
left outer join Orders O
    on C.CustomerID = O.CustomerID and year(O.OrderDate) = '1997'
group by C.CustomerID, CompanyName

--  Dla każdego klienta podaj liczbę zamówień w każdym z z lat 1997, 98

select C.CustomerID, CompanyName, year(OrderDate) as year, count(O.OrderID) as number_of_orders
from Customers C
left outer join Orders O
    on C.CustomerID = O.CustomerID and year(OrderDate) in (1997, 1998)
group by C.CustomerID, CompanyName, year(OrderDate);

-- Dla każdego klienta podaj liczbę zamówień w
-- każdym z miesięcy 1997, 98

 -- DODAĆ DLA KAŻDEGO MIESIĄCA

select C.CustomerID, CompanyName, year(OrderDate) as year, month(OrderDate) as month,
       count(O.OrderID) as number_of_orders
from Customers C
left outer join Orders O
    on C.CustomerID = O.CustomerID and year(OrderDate) in (1997, 1998)
group by C.CustomerID, CompanyName, year(OrderDate), month(OrderDate);


select C.CustomerID, CompanyName, year(OrderDate) as year, month(OrderDate) as month,
       count(O.OrderID) as number_of_orders
from Customers C
left outer join Orders O
    on C.CustomerID = O.CustomerID and year(OrderDate) in (1997, 1998)
group by C.CustomerID, CompanyName, year(OrderDate), month(OrderDate);

select 1, 2, 3

-- Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki dostarczała firma ‘United Package’

select distinct C.CustomerID, C.CompanyName, C.Phone
from Customers C
inner join Orders O
    on C.CustomerID = O.CustomerID
inner join Shippers S
    on O.ShipVia = S.ShipperID
where year(ShippedDate) = 1997 and S.CompanyName = 'United Package';

-- Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłek nie dostarczała firma ‘United Package’

select distinct C.CustomerID, C.CompanyName, C.Phone
from Customers C
left outer join Orders O
    on C.CustomerID = O.CustomerID and year(ShippedDate) = '1997'
left outer join Shippers S
    on O.ShipVia = S.ShipperID and S.CompanyName = 'United Package'
where S.ShipperID is null;
