/***
--> Digital Music Store - Data Analysis
Data Analysis project to help Chinook Digital Music Store to help how they can
optimize their business opportunities and to help answering business related questions.
***/

select * from album
select * from artist
select * from Customer
select * from Employee
select * from Genre
select * from Invoice
select * from Invoiceline
select * from Mediatype
select * from Playlist
select * from Playlisttrack
select * from Track




-- Using SQL solve the following problems using the chinook database.


--1) Find the artist who has contributed with the maximum no of albums. Display the artist name and the no of albums.


with cte as
			(select  ar.name as artist_name,
					 count(*) as no_of_albums,
					 rank()over(order by count(*) desc) as rnk
			from artist ar
			join album al
				on ar.artistid=al.artistid
			group by ar.name) 
select artist_name,no_of_albums
from cte
where rnk=1




--2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.


select Concat(c.firstName,' ',c.LastName) as Name,c.email,c.country,g.name as genre
from customer c
join invoice i
	on c.customerid=i.customerid
join invoiceline il
	on il.invoiceid=i.invoiceid
join track t
	on t.trackid=il.trackid
join genre g
	on g.genreid=t.genreid
where g.name in ('Jazz','Rock','Pop')





--3) Find the employee who has supported the most no of customers. Display the employee name and designation
 
with cte as
			(select  e.employeeid,
					concat(e.firstName,' ',e.LastName) as employee_name,
					e.title as designation,
					rank()over(order by count(c.customerid) desc) as rnk,
					count(c.customerid) as  no_of_customers
			from employee e
			join  customer c
				on e.employeeid = c.supportrepid
			group by e.employeeid,concat(e.firstName,' ',e.LastName),e.title)
select employee_name,designation
from cte
where rnk=1



--4) Which city corresponds to the best customers?

select * from Customer
select * from Invoice

with cte as
			(select  city,
					sum(total) as total_Amt,
					rank()over(order by sum(total) desc) as rnk
			from invoice i
			join customer c
				on i.customerid=c.customerid
			group by city)
select city
from cte
where rnk=1



--5) The highest number of invoices belongs to which country?
select * from Invoice
select * from Invoiceline

with cte as 
			(select  billingcountry as country,
					count(invoiceid) as highest_invoice,
					rank()over(order by count(invoiceid) desc) as rnk
			from invoice
			group by billingcountry)
select country
from cte
where rnk = 1


--6) Name the best customer (customer who spent the most money).
select* from customer
select* from invoice

with cte as
			(select  concat(c.firstname,' ',c.lastname) as name,
					sum(total) as money_spend,
					rank()over(order by sum(total) desc) as rnk
			from customer c
			join invoice i
				on c.customerid=i.customerid
			group by concat(c.firstname,' ',c.lastname))
select name
from cte
where rnk=1



--7) Suppose you want to host a rock concert in a city and want to know which location should host it.

select I.billingcity, count(1) as total
from Track T
join Genre G on G.genreid = T.genreid
join InvoiceLine IL on IL.trackid = T.trackid
join Invoice I on I.invoiceid = IL.invoiceid
where G.name = 'Rock'
group by I.billingcity
order by 2 desc;



8) --Identify all the albums who have less then 5 track under them.Display the album name, artist name and the no of tracks in the respective album.

select  a.title album_name,
		ar.name artist_name,
		count(*) as no_of_tracks
from track t
join album a
	on a.albumid=t.albumid
join artist ar
	on ar.artistid=a.artistid
group by a.title,ar.name
having count(*)<5
order by 3 desc




--9) Display the track, album, artist and the genre for all tracks which are not purchased.

select t.name as track,al.title as album,a.name as artist,g.name as genre
from artist a
join album al
	on a.artistid=al.artistid
join track t
	on t.albumid=al.albumid
join genre g
	on g.genreid=t.genreid
where not exists(
				select 1
				from invoiceline il
				where il.trackid=t.trackid
					)
--alternative solution

select t.name as track,al.title as album,a.name as artist,g.name as genre
from track t
left join invoiceline il
	on t.trackid=il.trackid
join album al
	on al.albumid=t.albumid
join artist a
	on a.artistid=al.artistid
join genre g
	on g.genreid=t.genreid
where il.trackid is null



--10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

with cte as
			(	select distinct a.name as artist_name,g.name as genre_name
				from artist a
				join album al
					on a.artistid=al.artistid
				join track t
					on al.albumid=t.albumid
				join genre g
					on t.genreid=g.genreid),
	cte2 as
			( select artist_name,count(*) as total_genre
				 from cte
				 group by artist_name
				 having count(*)>1
			)
select C.*
from cte c
join cte2 ce
	on c.artist_name=ce.artist_name
order by 1,2

--11) Which is the most popular and least popular genre?

with cte as
			(select g.name as genre_name,
					count(*) as no_of_tracks,
					rank()over(order by count(*)desc) as rnk
			from genre g
			join track t
				on g.genreid=t.genreid
			join invoiceline il
				on il.trackid=t.trackid
			group by g.name),
	temp as
			(select max(rnk) as least_popular			 
			from cte)

select  a.genre_name,
		Case when a.rnk = 1 then 'most popular' else 'least popular' end as popularity
from cte a
inner join temp b
on a.rnk= 1
or a.rnk =b.least_popular




--12) Identify if there are tracks more expensive than others. If there are then display the track name along with the album title and artist name for these expensive tracks.
select * from track
select * from album
select * from artist



select  t.name as track_name,
		al.title as album_title,
		a.name as artist_name
from track t
join album al
	on t.albumid=al.albumid
join artist a
	on a.artistid=al.artistid
where unitPrice>(select avg(UnitPrice) as price
				from track)



    
--13) Identify the 5 most popular artist for the most popular genre.Popularity is defined based on how many songs an artist has performed in for the particular genre.
--    Display the artist name along with the no of songs.
--    [Reason: Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
--    Lets invite the artists who have written the most rock music in our dataset.]


with cte1 as		
					(
					select genre_name as name
					from
						(select  g.name as genre_name,
								 count(*)as no_of_tracks,
								 rank()over(order by count(*) desc) as rnk
						from genre g
						join track t
							on g.genreid=t.genreid
						join invoiceline il
							on il.trackid=t.trackid
						group by g.name)x
					where rnk=1
					),
				
		cte2 as	
					(
						select  a.name as artist_name,
								count(*) as no_of_songs_performed,
								rank()over(order by count(*) desc) as rnk
						from artist a
						join album al
							on a.artistid=al.artistid
						join track t
						on t.albumid=al.albumid
						join genre g
							on g.genreid=t.genreid
						join cte1 c
							on g.name =c.name
						group by a.name

					)
select artist_name,no_of_songs_performed
from cte2
where rnk<=5




--14) Find the artist who has contributed with the maximum no of songs/tracks. Display the artist name and the no of songs.

select * from track
select * from album
select * from artist


select b.name
from
		(select  a.Name,
				count(*) as total_no_of_songs,
				rank()over(order by count(*) desc) as rnk
		from artist a
		join album al
			on a.artistid=al.ArtistId
		join track t
			on t.AlbumId=al.AlbumId
		group by a.Name)b
where b.rnk=1


--15) Are there any albums owned by multiple artist?
select * from album
select * from artist


select Albumid,count(*)
from album
group by Albumid
having count(*)>1
order by 1


 
--16) Is there any invoice which is issued to a non existing customer?
select * from Customer
select * from Invoice

select i.*
from Invoice i
left join Customer c
	on i.CustomerId=c.CustomerId
where i.CustomerId is null
order by 1

--alternate solution
select *
from Invoice i
where not exists( select 1 
					from Customer c
					where c.CustomerId=i.CustomerId)



--17) Is there any invoice line for a non existing invoice?


select *
from InvoiceLine il
where not exists(select 1
				 from InvoiceLine i
				 where i.InvoiceId=il.InvoiceId)



--18) Are there albums without a title?

select * from Album
where Title is null




--19) Are there invalid tracks in the playlist?
select * from PlaylistTrack
select * from Track


select  * from PlaylistTrack p
where not exists(select 1
				 from Track t
				 where t.TrackId=p.TrackId
				)