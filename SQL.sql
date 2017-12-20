USE sakila;

SELECT * FROM actor;

#1a. Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name FROM actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. 
# Name the column `Actor Name`. 
ALTER TABLE actor ADD `Actor Name` VARCHAR(50);

UPDATE actor SET `Actor Name` = CONCAT(first_name, " ", last_name);

#2a. You need to find the 
# ID number, first name, and last name of an actor, 
# of whom you know only the first name, "Joe." 
# What is one query would you use to obtain this information?

SELECT actor_id, `Actor Name` FROM actor WHERE first_name = "Joe";

#2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, `Actor Name` FROM actor WHERE last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters `LI`. 
# This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name FROM actor 
WHERE last_name LIKE '%LI%' OR first_name LIKE '%LI%';

#2d. Using `IN`, display the `country_id` and `country` columns 
# of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. Add a `middle_name` column to the table `actor`. 
# Position it between `first_name` and `last_name`. 
# Hint: you will need to specify the data type.
 
ALTER TABLE actor
ADD COLUMN `middle_name` VARCHAR(45) NOT NULL AFTER `first_name`;

#3b. You realize that some of these actors have tremendously long last names.
# Change the data type of the `middle_name` column to `blobs`.

UPDATE actor SET `middle_name` = 'blobs';

#3c. Now delete the `middle_name` column.

ALTER TABLE actor DROP `middle_name`;

#4a. List the last names of actors, 
# as well as how many actors have that last name.

SELECT last_name, count(*) as NUM FROM actor GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that 
# last name, but only for names that are shared by at least two actors.

SELECT last_name, count(*) as NUM FROM actor GROUP BY last_name HAVING count(*) > 1;


#4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered 
# in the `actor` table as `GROUCHO WILLIAMS`, 
# the name of Harpo's second cousin's husband's yoga teacher. 
# Write a query to fix the record.

UPDATE actor SET first_name = 'HARPO' WHERE `Actor Name`  = 'GROUCHO WILLIAMS';


#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
# It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`,
# change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, 
# as that is exactly what the actor will be with the grievous error. 
# BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 
# (Hint: update the record using a unique identifier.)

UPDATE actor SET first_name = 'MUCHO GROUCHO' WHERE first_name = 'HARPO';

UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO';

# Update `Actor Name`

UPDATE actor SET `Actor Name` = CONCAT(first_name, " ", last_name);


#5a. You cannot locate the schema of the `address` table.
# Which query would you use to re-create it?

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) 


#6a. Use `JOIN` to display the first and last names, 
# as well as the address, of each staff member. 
# Use the tables `staff` and `address`:

SELECT * FROM staff; 

SELECT staff.first_name, staff.last_name, address.address, 
address.city_id, address.postal_code 
FROM staff INNER JOIN address ON staff.address_id =  address.address_id;

#6b. Use `JOIN` to display the total amount rung up 
# by each staff member in August of 2005. Use tables `staff` and `payment`. 

SELECT staff.first_name, staff.last_name, sum(payment.amount) AS 'Total Amount'
FROM staff INNER JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date >= '2005-08-01' GROUP BY staff.first_name, staff.last_name
;

#6c. List each film and the number of actors who are listed for that film. 
# Use tables `film_actor` and `film`. Use inner join.

SELECT film.film_id, count(film_actor.actor_id) AS 'Actor Count'
FROM film INNER JOIN film_actor ON film.film_id = film_actor.film_id 
GROUP BY film.film_id;

#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT film_id, count(inventory_id) AS 'Copies' FROM inventory 
WHERE film_id IN
(SELECT film.film_id FROM film WHERE film.title = 'Hunchback Impossible')
GROUP BY film_id;


#6e. Using the tables `payment` and `customer` and the `JOIN` command,
# list the total paid by each customer. List the customers alphabetically by last name:

SELECT customer.customer_id, customer.first_name, customer.last_name, sum(payment.amount) as 'Total Paid'
FROM customer INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer_id ORDER BY customer.last_name; 

 #7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
 # As an unintended consequence, films starting with the letters `K` and `Q` have 
 # also soared in popularity. Use subqueries to display the titles of movies 
 # starting with the letters `K` and `Q` whose language is English. 
 
SELECT * FROM film ;

SELECT film.title FROM film WHERE film.title IN
(SELECT film.title FROM film WHERE film.language_id = '1')
AND (film.title LIKE "K%" OR film.title LIKE "Q%"); 
 
 #7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name FROM actor WHERE actor_id IN
(SELECT actor_id FROM film_actor WHERE film_id IN
(SELECT film_id from film where film.title = 'Alone Trip')); 
   
# 7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.

SELECT customer.address_id, customer.first_name, customer.last_name, customer.email 
AS 'email' FROM customer
INNER JOIN 
(SELECT address.address_id, address.address AS b FROM address WHERE city_id IN 
(SELECT city_id AS b1 FROM city WHERE country_id IN
(SELECT country_id AS b2 FROM country WHERE country = 'Canada'))) AS b3
ON customer.address_id  = b3.address_id; 


# 7d. Sales have been lagging among young families, 
#and you wish to target all family movies for a promotion. 
#Identify all movies categorized as famiy films.

SELECT film_id, title FROM film WHERE film_id IN
(SELECT film_id FROM film_category WHERE category_id IN
(SELECT category_id FROM category WHERE name = 'Family')) ;


# 7e. Display the most frequently rented movies in descending order.
SELECT film.title, count(film.title) AS count 
FROM rental
		LEFT JOIN
	payment ON payment.customer_id = rental.customer_id
		LEFT JOIN
	inventory ON inventory.inventory_id = rental.inventory_id
		LEFT JOIN film ON film.film_id = inventory.film_id 
GROUP BY film.title 
ORDER BY count DESC; 

    
# 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT staff.store_id, sum(payment.amount) AS 'Total $' 
FROM staff 
	LEFT JOIN 
    payment ON payment.staff_id = staff.staff_id
GROUP BY staff.store_id;
    

# 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country 
	FROM address 
	JOIN store ON store.address_id = address.addrdess_id 
    JOIN city ON address.city_id = city.city_id 
    JOIN country ON city.city_id = country.city_id;
    
  	
# 7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: 
#category, film_category, inventory, payment, and rental.)


SELECT category.name, sum(payment.amount) AS 'Gross Revenue'
	FROM film_category
    JOIN category ON film_category.category_id = category.category_id
    JOIN film ON  film_category.film_id = film.film_id
    JOIN inventory ON film.film_id = inventory.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) DESC
limit 5;


# 8a. In your new role as an executive, 
#you would like to have an easy way of viewing 
#the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW `Top Genres` AS
SELECT category.name, sum(payment.amount) AS 'Gross Revenue'
	FROM film_category
    JOIN category ON film_category.category_id = category.category_id
    JOIN film ON  film_category.film_id = film.film_id
    JOIN inventory ON film.film_id = inventory.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) DESC
limit 5;
  	
# 8b. How would you display the view that you created in 8a?
SELECT * FROM  `Top Genres`;
# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW `Top Genres`;