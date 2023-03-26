-- Porównywanie napisów

--1. Szukamy informacji o produktach sprzedawanych w butelkach (‘bottle’)
select * from Products where QuantityPerUnit like '%bottles%';
-- 2. Wyszukaj informacje o stanowisku pracowników, których nazwiska zaczynają się
-- na literę z zakresu od B do L
select * from Employees where LastName like '[B-L]%';

select * from Employees where substring(LastName, 1, 1) between 'B' and 'L';

select * from Employees where LEFT(LastName, 1) between 'B' and 'L';

select * from Employees where LastName >= 'B' and LastName < 'M';
-- 3. Wyszukaj informacje o stanowisku pracowników, których nazwiska zaczynają się
-- na literę B lub L
select * from Employees where LastName like '[BL]%';
-- 4. Znajdź nazwy kategorii, które w opisie zawierają przecinek
select CategoryName from Categories where Description like '%,%';
-- 5. Znajdź klientów, którzy w swojej nazwie mają w którymś miejscu słowo ‘Store’
select * from Customers where CompanyName like '%Store%';

-- Zakres wartości

-- 1. Szukamy informacji o produktach o cenach mniejszych niż 10 lub większych niż 20
select * from Products where UnitPrice < 10 or UnitPrice > 20
-- 2. Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00
select ProductName, UnitPrice from Products where UnitPrice between 20 and 30;

-- Warunki logiczne

-- 1. Wybierz nazwy i kraje wszystkich klientów mających siedziby w Japonii (Japan)
-- lub we Włoszech (Italy)
select CompanyName, Country from Customers where Country in ('Japan', 'Italy');

-- Ćwiczenie

-- Napisz instrukcję select tak aby wybrać numer zlecenia, datę zamówienia, numer
-- klienta dla wszystkich niezrealizowanych jeszcze zleceń, dla których krajem
-- odbiorcy jest Argentyna
select OrderId, OrderDate, CustomerID
        from Orders
        where (ShippedDate is null or ShippedDate > getdate()) and ShipCountry = 'Argentina';
select getdate();

-- Ćwiczenie

-- 1. Napisz polecenie, które oblicza wartość każdej pozycji zamówienia o numerze 10250
select *, round(UnitPrice * Quantity * (1 - Discount), 2) as Price
from [Order Details]
where OrderId = 10250;

select *, cast(UnitPrice * Quantity * (1 - Discount) as decimal(10, 2)) as Price
from [Order Details]
where OrderId = 10250;
-- 2. Napisz polecenie które dla każdego dostawcy (supplier) pokaże pojedynczą
-- kolumnę zawierającą nr telefonu i nr faksu w formacie
-- (numer telefonu i faksu mają być oddzielone przecinkiem)
select CompanyName, concat(Phone, ', ', Fax) as [Phone, Fax] from Suppliers;
select CompanyName, IIF(Fax is NULL, Phone, concat(Phone, ', ', Fax)) as [Phone, Fax] from Suppliers;
select CompanyName, isnull(Fax, 'brak, ') + isnull(Phone, 'brak') as [Phone, Fax] from Suppliers;
select CompanyName, concat(Phone, isnull(', '+ Fax, '')) as [Phone, Fax] from Suppliers;
-- Order by

-- 1. Wybierz nazwy i kraje wszystkich klientów, wyniki posortuj według kraju, w
-- ramach danego kraju nazwy firm posortuj alfabetycznie
select CompanyName, Country from Customers order by Country, CompanyName;
-- 2. Wybierz informację o produktach (grupa, nazwa, cena), produkty posortuj wg
-- grup a w grupach malejąco wg ceny
select Products.ProductName, Products.UnitPrice, Categories.CategoryName
from Products
inner join Categories on Products.CategoryID = Categories.CategoryID
order by Categories.CategoryName, Products.UnitPrice desc;
-- 3. Wybierz nazwy i kraje wszystkich klientów mających siedziby w Japonii (Japan)
-- lub we Włoszech (Italy), wyniki posortuj tak jak w pkt 1
select CompanyName, Country from Customers where Country in ('Italy', 'Japan')
order by Country, CompanyName;


-- pokaż zamówienia złożone w marcu 97
select * from Orders where OrderDate >= '1997-03-01' and '1997-04-01' > OrderDate;
-- Dla każdego zamówienia wyświetl ile dni upłynęło od daty zamówienia do daty wysyłki
select OrderID, OrderDate, ShippedDate, datediff(day, OrderDate, ShippedDate) as diference
from Orders;
-- Pokaz przeterminowane zamówienia
select OrderID, RequiredDate
from Orders
where ShippedDate is null and RequiredDate < getdate();
-- Ile lat przepracował w firmie każdy z pracowników?
select FirstName, LastName, datediff(year, HireDate, getdate()) as 'work years' from Employees;
-- Dla każdego pracownika wyświetl imię, nazwisko oraz wiek
select FirstName, LastName, datediff(year, BirthDate, getdate()) as 'age' from Employees;
-- Wyświetl wszystkich pracowników, którzy mają teraz więcej niż 25 lat.
select FirstName, LastName from Employees where datediff(year, BirthDate, getdate()) > 25;
-- Policz średnią liczbę miesięcy przepracowanych przez każdego pracownika
select avg(datediff(month, HireDate, getdate())) from Employees;
select sum(datediff(month, HireDate, getdate()))/count(HireDate) from Employees;
-- Wyświetl dane wszystkich pracowników, którzy przepracowali w firmie co najmniej
-- 320 miesięcy, ale nie więcej niż 333
select * from Employees where datediff(month, HireDate, getdate()) >= 320 and 333 >= datediff(month, HireDate, getdate());
-- Dla każdego pracownika wyświetl imię, nazwisko, rok urodzenia, rok, w którym został
-- zatrudniony, oraz liczbę lat, którą miał w momencie zatrudnienia
select FirstName, LastName, BirthDate, HireDate, datediff(year, BirthDate, HireDate) as hire_age
from Employees;
-- Dla każdego pracownika wyświetl imię, nazwisko oraz rok, miesiąc i dzień jego
-- urodzenia oraz dzień tygodnia w jakim się urodził
select FirstName, LastName, year(BirthDate) as 'Birth year', month(BirthDate) as 'Birth month',
       day(BirthDate) as 'Birth day', datename(weekday, BirthDate) as 'Birth day of week'
from Employees;

select FirstName, LastName, left(BirthDate, 11), datename(weekday, BirthDate) as 'Birth day of week'
from Employees;
-- Policz, z ilu liter składa się najkrótsze imię pracownika
select min(len(FirstName)) from Employees;
-- Wyświetl, ile lat minęło od daty 1 stycznia 1990 roku.
select datediff(year, '1990-01-01', getdate());


-- LIBRARY

use library;

-- Ćwiczenie 1

-- 1. Napisz polecenie select, za pomocą którego uzyskasz tytuł i numer książki
select title, title_no from title;
-- 2. Napisz polecenie, które wybiera tytuł o numerze 10
select title from title where title_no = 10;
-- 3. Napisz polecenie select, za pomocą którego uzyskasz numer książki (nr tyułu) i
-- autora z tablicy title dla wszystkich książek, których autorem jest Charles
--Dickens lub Jane Austen
select title_no, author from title where author in ('Charles Dickens', 'Jane Austen');

-- Ćwiczenie 2

-- 1. Napisz polecenie, które wybiera numer tytułu i tytuł dla wszystkich książek,
-- których tytuły zawierających słowo „adventure”
select title_no, title from title where title like '%adventure%';
-- 2. Napisz polecenie, które wybiera numer czytelnika, oraz zapłaconą karę
select member_no, fine_paid from loanhist; -- where fine_paid is not null
-- 3. Napisz polecenie, które wybiera wszystkie unikalne pary miast i stanów z tablicy
-- adult.
select distinct state, city from adult;
-- 4. Napisz polecenie, które wybiera wszystkie tytuły z tablicy title i wyświetla je w
-- porządku alfabetycznym.
select title from title order by title;

-- Ćwiczenie 3

/*
 1. Napisz polecenie, które:
– wybiera numer członka biblioteki (member_no), isbn książki (isbn) i watrość
naliczonej kary (fine_assessed) z tablicy loanhist dla wszystkich wypożyczeń
dla których naliczono karę (wartość nie NULL w kolumnie fine_assessed)
– stwórz kolumnę wyliczeniową zawierającą podwojoną wartość kolumny
fine_assessed
– stwórz alias ‘double fine’ dla tej kolumny
 */

select member_no, isbn, fine_assessed, fine_assessed * 2 as 'double fine'
from loanhist
where fine_assessed is not null;

-- Cwiczenie 4

/*
 1. Napisz polecenie, które
– generuje pojedynczą kolumnę, która zawiera kolumny: firstname (imię
członka biblioteki), middleinitial (inicjał drugiego imienia) i lastname
(nazwisko) z tablicy member dla wszystkich członków biblioteki, którzy
nazywają się Anderson
– nazwij tak powstałą kolumnę email_name (użyj aliasu email_name dla
kolumny)
– zmodyfikuj polecenie, tak by zwróciło „listę proponowanych loginów e-mail”
utworzonych przez połączenie imienia członka biblioteki, z inicjałem
drugiego imienia i pierwszymi dwoma literami nazwiska (wszystko małymi
małymi literami).
– Wykorzystaj funkcję SUBSTRING do uzyskania części kolumny
znakowej oraz LOWER do zwrócenia wyniku małymi literami.
Wykorzystaj operator (+) do połączenia stringów.
 */

select lower(concat(replace(firstname, ' ', ''), middleinitial, substring(lastname, 1, 2))) as email_name
from member
where lastname = 'anderson'
order by email_name;

-- Ćwiczenie 5

/*
 1. Napisz polecenie, które wybiera title i title_no z tablicy title.
§ Wynikiem powinna być pojedyncza kolumna o formacie jak w przykładzie
poniżej:
The title is: Poems, title number 7
§ Czyli zapytanie powinno zwracać pojedynczą kolumnę w oparciu o
wyrażenie, które łączy 4 elementy:
stała znakowa ‘The title is:’
wartość kolumny title
stała znakowa ‘title number’
wartość kolumny title_no
 */

select  'The title is: ' + title + ', title number ' + cast(title_no as varchar)
from title;
