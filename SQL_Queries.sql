-- Are there customers that share the same address?. If yes, display the customer names

SELECT c1.first_name, c1.last_name
FROM customer AS c1
JOIN customer AS c2
ON c1.customer_id <> c2.customer_id
AND c1.address_id = c2.address_id;

-- What is the name of the customer who made the highest total payments

SELECT first_name || ' ' || last_name AS names
FROM ( 
	SELECT c.first_name, c.last_name, SUM(amount) AS total_amount
	FROM payment AS p
	JOIN customer AS c
	ON p.customer_id = c.customer_id
	GROUP BY p.customer_id, c.first_name, c.last_name
	ORDER BY total_amount DESC 
) AS subquery
LIMIT 1;

-- What movie(s) that was rented the most?

SELECT title, COUNT(title) AS rental_count
FROM film AS f
INNER JOIN inventory AS i
USING (film_id)
INNER JOIN rental AS r
USING (inventory_id)
GROUP BY title
ORDER BY rental_count DESC
LIMIT 1;

-- Which movies have been rented so far?

SELECT title
FROM film
WHERE film_id IN ( SELECT DISTINCT film_id
					FROM rental AS r
					JOIN inventory AS i
					USING (inventory_id));


-- Which movies have not been rented so far?

SELECT title
FROM film
WHERE film_id NOT IN ( SELECT DISTINCT film_id
					FROM rental AS r
					JOIN inventory AS i
					USING (inventory_id));

-- Which customers have not rented any movies so far?

SELECT first_name, last_name
FROM customer
WHERE customer_id NOT IN (SELECT DISTINCT customer_id
						   FROM rental);

-- Display each movie and the number of times it got rented

SELECT f.title, COUNT(i.film_id) AS rent_count
FROM film AS f
JOIN inventory AS i
USING(film_id)
JOIN rental AS r
USING(inventory_id)
GROUP BY i.film_id, f.title
ORDER BY i.film_id;

-- Show the first name and last name and the number of films each actor acted in

SELECT a.first_name, a.last_name, COUNT(f.film_id) AS film_count
FROM actor AS a
JOIN film_actor AS f
ON a.actor_id = f.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY a.actor_id;

-- Display the names of all the actors that acted in more than 20 movies

SELECT a.first_name, a.last_name
FROM actor AS a
JOIN film_actor AS f
ON a.actor_id = f.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(f.film_id) > 20
ORDER BY a.actor_id;

-- For all movies rated “PG” how many times did it get rented

SELECT f.title, COUNT(i.film_id) AS film_count
FROM film AS f
JOIN inventory AS i
USING(film_id)
JOIN rental AS r
USING(inventory_id)
WHERE rating = 'PG'
GROUP BY i.film_id, f.title
ORDER BY i.film_id;

-- What movies are offered for rent in store_id 1 and not offered in store_id 2?

SELECT film_id
FROM inventory
WHERE store_id = 1
AND film_id NOT IN (SELECT film_id
					FROM inventory
					WHERE store_id = 2)
ORDER BY film_id;

-- What movies are offered for rent in any of the two stores 1 and 2?

SELECT film_id
FROM inventory
WHERE store_id = 1 AND store_id = 2
ORDER BY title

-- What movies are offered in both stores at the same time?

SELECT title
FROM film
WHERE film_id IN (SELECT film_id
				   FROM inventory
				   WHERE store_id = 1
	AND film_id IN (SELECT film_id
					 FROM inventory
					 WHERE store_id = 2)) 
ORDER BY film_id;

-- Display the movie title for the most rented movie in the store with store_id 1

CREATE TEMP TABLE store AS 
SELECT film_id, COUNT(film_id)
FROM rental
JOIN inventory
USING (inventory_id)
WHERE store_id = 1
GROUP BY film_id
ORDER by count DESC;

SELECT title
FROM film
JOIN store
USING(film_id)
LIMIT 1

-- How many movies are not offered for rent in the stores yet?

CREATE VIEW movies AS 
SELECT film_id 
FROM film
WHERE film_id NOT IN (SELECT film_id
					  FROM inventory
					  WHERE store_id = 1
					  UNION
					  SELECT film_id
					  FROM inventory
					  WHERE store_id = 2);

SELECT COUNT(DISTINCT film_id)
FROM movies

-- How many rented movies are under each rating?

SELECT rating, COUNT(i.film_id)
FROM film AS f
JOIN inventory AS i
ON f.film_id = i.film_id
JOIN rental AS r
ON i.inventory_id = r.inventory_id
GROUP BY rating;

-- How much profit have each of the stores 1 and 2 gained?

SELECT store_id, SUM(amount) AS profits
FROM payment
JOIN rental 
USING(rental_id)
JOIN inventory
USING (inventory_id)
GROUP BY store_id;