-- Chinook Database

-- Q1: ۱۰ آهنگ برتر که بیشترین درامد رو داشتن به همراه درامد ایجاد شده
select t.TrackID, t.name as TrackName, il.unitprice, 
sum(il.quantity) as TotalOrders, 
sum(il.unitprice * il.quantity)  as TotalRevenue 
from track as t
join invoiceLine as il 
on t.trackId = il.trackId
group by t.trackID, t.name, il.unitprice
order by TotalRevenue desc
limit 10;


-- Q2: محبوب ترین ژانر، به ترتیب از نظر تعداد اهنگ‌های فروخته شده و کل درامد
select g.genreID, g.name as GenreName, 
sum(il.quantity) as TotalOrders, 
sum(il.unitprice * il.quantity)  as TotalRevenue 
from genre as g
join track as t on g.genreID = t.genreID
join invoiceLine as il on t.trackId = il.trackId
group by g.genreID, g.name
order by TotalOrders desc, TotalRevenue desc
limit 1;


-- Q3: کاربرانی که تا حالا خرید نداشتند
-- Solution 1: Left Join
select c.customerId, concat(c.firstname,"  ", c.lastname) as FullName
from customer as c
left join invoice as i on c.customerID = i.customerID
where i.CustomerId is NUll
group by c.customerId, FullName;

-- Solution 2: Not Exists
select c.customerId, concat(c.firstname,"  ", c.lastname) as FullName
from customer as c
where not exists (
	select customerId from Invoice as i
    where i.customerId = c.customerId);


-- Q4: میانگین زمان آهنگ‌ها در هر آلبوم
select AlbumID, round(avg(milliseconds)/60000, 2) as AverageMinute
from track 
group by albumId;


-- Q5: کارمندی که بیشترین تعداد فروش را داشته
select e.employeeID, 
	concat(e.firstname, " ", e.lastname) as EmployeeName, 
	e.title as JobTitle ,
	sum(i.total) as TotalSale
from employee as e
	join customer as c on e.employeeID = c.supportrepID
	join invoice as i on c.customerID = i.customerID
group by e.employeeID, EmployeeName
order by TotalSale desc
limit 1;


-- Q6: کاربرانی که از بیش از یک ژانر خرید کردند
with customer_genre as
(
select c.customerId, 
	concat(c.firstname,"  ", c.lastname) as FullName, 
	g.genreID, 
	g.name as GenreName
from customer as c
	join invoice as i on c.customerId = i.customerId
	join InvoiceLine as il on i.InvoiceId = il.InvoiceId
	join track as t on il.trackId = t.trackID
	join genre as g on t.genreID = g.genreID 
group by c.customerId, Fullname, g.genreID, GenreName
)
select cg.Fullname, count(distinct cg.genrename) as NoOfDifferentGenres
from customer_genre as cg
group by cg.Fullname 
having NoOfDifferentGenres > 1
order by NoOfDifferentGenres desc;


-- Q7: سه اهنگ برتر از نظر درامد فروش برای هر ژانر
select  *
from
(select g.Name as GenreName, 
t.name as TrackName, 
sum(il.quantity) as TotalSale,
row_number() over (partition by g.name order by sum(il.quantity) desc) as sale_rank
from Genre as g
	Join track as t on g.genreID = t.genreID
    join invoiceline as il on t.trackID = il.trackID
group by g.genreID, GenreName, t.trackID, TrackName
) 
as ranked_tracks
where 
	sale_rank <= 3
    order by GenreName, TotalSale desc ;


-- Q8: تعداد اهنگ‌های فروخته شده به صورت تجمعی در هر سال به صورت جداگانه
with sales_each_year as 
(
select 
year(i.invoicedate) as Year, 
sum(il.quantity) as TotalSale
from invoice as i
	join invoiceline as il on i.invoiceID = il.invoiceID
group by Year
)
select Year, TotalSale,
Sum(TotalSale) over (order by year) AS CumulativeSales
from sales_each_year 
group by Year, TotalSale;

    




-- Q9: کاربرانی که مجموع خریدشان بالاتر از میانگین مجموع خرید تمام کاربران است
with TotalSale as
(
select c.CustomerId, concat(c.firstname, " ", c.lastname) as CustomerName, 
sum(i.total) as TotalSale 
from customer as c
join invoice as i on c.customerID = i.customerID
group by c.customerId, customername
order by totalsale desc
),
AverageSale as
(
select avg(totalsale) as Averagesale
from TotalSale  
)
select 
ts.CustomerId, ts.CustomerName, ts.TotalSale, round(avs.AverageSale, 2) as AverageSale
from Totalsale as ts
join AverageSale  as avs on ts.TotalSale > Avs.Averagesale
order by ts.TotalSale desc;

