/*1. senior most employee based on job title?*/

select* from employee
order by levels desc
limit 1;

/*2.countries have most invoices*/

select COUNT(*) as sum, billing_country 
from invoice
group by billing_country
order by sum desc;

/*3.top 3 values of total invoice*/

select billing_country, total 
from invoice
order by total desc
limit 3;

/*4.city with best customers*/

select SUM(total) as invoice_total, billing_city

from invoice
group by billing_city
order by invoice_total desc;

/*5.coustomer who have spent most*/
select customer.customer_id , customer.first_name , customer.last_name, SUM (invoice.total) as total
from customer
join invoice ON customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total DESC
limit 1;

/*6.query to return a email , first and last name, genre of all rock music listeners
Return list ordered alphabetically by email starting with A*/

select DISTINCT email, first_name, last_name 
from customer
join invoice ON customer.customer_id= invoice.customer_id
join invoice_line ON invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
     select track_id from track
     join genre ON track.genre_id = genre.genre_id
     where genre.name LIKE 'Rock'
)
order by email;

/*7. atrist with most rock music and number of music*/
select artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
from track
join album ON album.album_id = track.album_id
join artist ON artist.artist_id= album.artist_id
join genre ON genre.genre_Id= track.genre_id
where genre.name LIKE 'Rock'
group by artist.artist_id
order by number_of_songs DESC
LIMIT 10;

/*8.Track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first*/

select name,milliseconds
from track
where milliseconds > (
   select AVG(milliseconds) AS avg_track_length
   from track)
order by milliseconds DESC;

/*9.Amount spent on artist by each customer*/

WITH best_selling_artist AS (
	select artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	from invoice_line
	join track ON track.track_id = invoice_line.track_id
	join album ON album.album_id = track.album_id
	join artist ON artist.artist_id = album.artist_id
	group BY 1
	order BY 3 DESC
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
from invoice i
join customer c ON c.customer_id = i.customer_id
join invoice_line il ON il.invoice_id = i.invoice_id
join track t ON t.track_id = il.track_id
join album alb ON alb.album_id = t.album_id
join best_selling_artist bsa ON bsa.artist_id = alb.artist_id
group BY 1,2,3,4
order BY 5 DESC;

/*most popular music genre for each country */

WITH popular_genre AS 
(
    select COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    from invoice_line 
	join invoice ON invoice.invoice_id = invoice_line.invoice_id
	join customer ON customer.customer_id = invoice.customer_id
	join track ON track.track_id = invoice_line.track_id
	join genre ON genre.genre_id = track.genre_id
	group BY 2,3,4
	order BY 2 ASC, 1 DESC
)
select * from popular_genre where RowNo <= 1;

/*query that determines the customer that has spent the most on music for each country*/

WITH Customter_with_country AS (
		select customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country 
	    order BY SUM(total) DESC) AS RowNo 
		from invoice
		join customer ON customer.customer_id = invoice.customer_id
		group BY 1,2,3,4
		order BY 4 ASC,5 DESC)
select * from Customter_with_country where RowNo <= 1;





