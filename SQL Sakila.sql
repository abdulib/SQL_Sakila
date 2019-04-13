USE sakila;

-- Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(`first_name`, ' ', `last_name`) AS ActorName
FROM actor;

-- Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT * 
FROM actor
WHERE first_name = 'Joe';

-- Find all actors whose last name contain the letters GEN
SELECT * 
FROM actor
WHERE last_name LIKE '%GEN%';

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * 
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB;

-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column
ALTER TABLE actor
DROP COLUMN description;

--  List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(last_name) AS 'Count Of Last Name'
FROM actor
GROUP BY last_name;

SELECT last_name, COUNT(last_name) AS 'Count Of Last Name'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
-- locate GROUCHO WILLIAMS actor_id & View after updating
SELECT * 
FROM actor
WHERE last_name = 'williams';

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

-- Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
SELECT * 
FROM actor
WHERE last_name = 'williams';

UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

--  Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address 
ON staff.address_id = address.address_id;

-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, SUM(payment.amount) as "Total Amount"
FROM staff
LEFT JOIN payment
ON staff.staff_id = payment.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY staff.first_name;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS "Number of Actors"
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, COUNT(inventory.film_id) AS "Number of Copies"
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
WHERE film.title = "Hunchback Impossible";

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) as "Total Amount Paid"
FROM customer
LEFT JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY customer.first_name, customer.last_name
order by customer.last_name;

--  The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT film.title
FROM film
WHERE film.title LIKE "K%" OR film.title LIKE "Q%" AND film.language_id = 1;

--  Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
from actor
where actor_id in
				(SELECT actor_id
				from film_actor
				where film_id in
								(SELECT film_id
								from film
								where title = "Alone Trip")
								);
                                
-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id
LEFT JOIN city
ON address.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id
WHERE country = "Canada";

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT title
FROM film
WHERE film_id in
        (SELECT film_id
		 FROM film_category
		 WHERE category_id in
				(SELECT category_id
				 FROM category
				 WHERE name = "Family")
                 );
                 
--  Display the most frequently rented movies in descending order.
SELECT title, COUNT(film.film_id) as "Most Frequently Rented"
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY COUNT(film.film_id) DESC;



-- Write a query to display how much business, in dollars, each store brought in.
SELECT staff.store_id as Store , SUM(payment.amount) as "Store Revenue"
FROM staff
JOIN payment 
ON staff.staff_id = payment.staff_id
group by staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id AS "Store ID", city.city AS "City", country.country AS "Country"
FROM store
JOIN address
ON store.address_id = address.address_id
JOIN city
ON address.city_id = city.city_id
JOIN country
on city.country_id = country.country_id;

-- List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name AS "Category Name", SUM(payment.amount) as "Gross Revenue"
FROM  category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment 
ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY category.name 
LIMIT 5;



-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS 
SELECT category.name AS "Category Name", SUM(payment.amount) as "Gross Revenue"
FROM  category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment 
ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY category.name 
LIMIT 5;


-- How would you display the view that you created in 8a?
SELECT * 
FROM top_five_genres;

-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres

