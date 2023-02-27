/* Airbnb Asheville, NC data analysis by James Paumen

This dataset was downloaded from http://insideairbnb.com/ and includes the listings and calendar table from 12/22 - 12/23. Archived
datasets are also available but require a purchase. For the purpose of this project, I will only be using this data set for the sake
of exploring data and discovering insights that be relevant to making data driven decisions.

*/
/** Name of the database I am working with **/
use airbnb;

/*How many hosts are there currently in Asheville, NC and how many airbnb listings are there?*/
SELECT COUNT(DISTINCT host_id) AS no_of_hosts
, COUNT(DISTINCT id) as no_of_listings
FROM dbo.listings;
--1,943 hosts and 3,093 airbnb listings. Some hosts have multiple properties.

/**Hosts with multiple listings?**/
SELECT host_name
, host_id
, COUNT (id) as no_of_listings
FROM dbo.listings
GROUP BY host_id, host_name
ORDER BY no_of_listings DESC;
--We can see that the host with the highest # of listings have as much as 119 properties While the majority of hosts have 1.

/*Let's see if we can find a percentage of hosts who have 1, 2, 3, 4, 5, 6-10, 11-50, 50+ listings
This cte finds the total sum of all listings. Additionally, I start assigning grouped listings because there are some hosts
that have as many as 119 listings. However, the majority of Airbnb hosts have a modest number of listings that they own.*/

--This cte takes the count of listings, the sum of the count of listings, and then I have a case statement grouping the number
--of listings in (1, 2, 3, 4, 5-10, 11-50, and 50+)
WITH cte_group AS (	
	SELECT 
	b.no_of_listings AS no_of_listings
	, CAST(b.count_of_listings AS float) AS count_of_listings
	, CAST(SUM(count_of_listings) OVER() AS float) as sum_of_listings
	, CASE WHEN no_of_listings = 1 THEN '1'
	WHEN no_of_listings = 2 THEN '2'
	WHEN no_of_listings = 3 THEN '3'
	WHEN no_of_listings = 4 THEN '4'
	WHEN no_of_listings BETWEEN 5 AND 10 THEN '5-10'
	WHEN no_of_listings BETWEEN 11 AND 50 THEN '11-50'
	ELSE '50+'
	END AS grouped_listings
	FROM
		--The first inner query finds how many listings each host has. The second inner query groups together the number of listings
		--and counts the number of listings for each group. E.g. there are 255 hosts who have 2 Airbnb listings
		(SELECT a.no_of_listings, COUNT(a.no_of_listings) AS count_of_listings
		 FROM (SELECT COUNT(id) as no_of_listings
			   FROM dbo.listings
			   GROUP BY host_id) AS a
		 GROUP BY no_of_listings) AS b
	)
--This outer query calculates the percentage of grouped listings and orders them in descending order
SELECT grouped_listings
, ROUND(SUM((count_of_listings / sum_of_listings) * 100), 2) as pct
FROM cte_group
GROUP BY grouped_listings
ORDER BY pct DESC;
/*This query provides insightful data because now we can see that the market for Airbnb hosts in Asheville is dominated by those
who have 1, 2, or 3 listings. While this is no indicator of success, we can draw a conclusion that the barrier for entry
for Ashevile Airbnb is low. */



/*Find the total revenue for each fiscal quarter of 2023 based on room types. 
We are using the calendar table to grab the price, availability, and the date. We are also joining that with the listings table
to grab room type.*/
--Each cte is calcuating the average price and count based on room types and availability by each fiscal quarter. 
WITH Q1_revenue AS(
SELECT list.room_type AS room_type
, AVG(cal.adjusted_price) AS avg_adjusted_price
, COUNT(list.room_type) AS count_booked_room_type
, ROUND(AVG(cal.adjusted_price) * COUNT(list.room_type), 2) AS Q1_revenue_by_room_type
FROM dbo.calendar cal
LEFT JOIN dbo.listings list
	ON cal.listing_id = list.id
WHERE cal.available = 'f' AND YEAR(date) = 2023 AND MONTH(date) IN (1, 2, 3)
GROUP BY list.room_type)
, Q2_revenue AS(
SELECT list.room_type
, AVG(cal.adjusted_price) AS avg_adjusted_price
, COUNT(list.room_type) AS count_booked_room_type
, ROUND(AVG(cal.adjusted_price) * COUNT(list.room_type), 2) AS Q2_revenue_by_room_type
FROM dbo.calendar cal
LEFT JOIN dbo.listings list
	ON cal.listing_id = list.id
WHERE cal.available = 'f' AND YEAR(date) = 2023 AND MONTH(date) IN (4, 5, 6)
GROUP BY list.room_type)
, Q3_revenue AS(
SELECT list.room_type
, AVG(cal.adjusted_price) AS avg_adjusted_price
, COUNT(list.room_type) AS count_booked_room_type
, ROUND(AVG(cal.adjusted_price) * COUNT(list.room_type), 2) AS Q3_revenue_by_room_type
FROM dbo.calendar cal
LEFT JOIN dbo.listings list
	ON cal.listing_id = list.id
WHERE cal.available = 'f' AND YEAR(date) = 2023 AND MONTH(date) IN (7, 8, 9)
GROUP BY list.room_type)
, Q4_revenue AS(
SELECT list.room_type
, AVG(cal.adjusted_price) AS avg_adjusted_price
, COUNT(list.room_type) AS count_booked_room_type
, ROUND(AVG(cal.adjusted_price) * COUNT(list.room_type), 2) AS Q4_revenue_by_room_type
FROM dbo.calendar cal
LEFT JOIN dbo.listings list
	ON cal.listing_id = list.id
WHERE cal.available = 'f' AND YEAR(date) = 2023 AND MONTH(date) IN (10, 11, 12)
GROUP BY list.room_type)

--This outer query calculcates the total revenue for each fiscal quarter
SELECT SUM(q1.Q1_revenue_by_room_type) AS q1_total_revenue
, SUM(q2.Q2_revenue_by_room_type) AS q2_total_revenue
, SUM(q3.Q3_revenue_by_room_type) AS q3_total_revenue
, SUM(q4.Q4_revenue_by_room_type) AS q4_total_revenue
FROM Q1_revenue AS q1
INNER JOIN Q2_revenue AS q2
	ON q1.room_type = q2.room_type
INNER JOIN Q3_revenue AS q3
	ON q1.room_type = q3.room_type
INNER JOIN Q4_revenue AS q4
	ON q1.room_type = q4.room_type
/*As we can see from this analysis, Q1 performs the best and drops off Q2. It picks back up in Q3 and there's a slight drop in revenue
in Q4. Overall, revenue is very similar for all quarters aside from a big difference in Q2. This implies that the Airbnb business
is not as profitable during the spring time, in Asheville at least. */


/*With this query, we are selecting the latitude and longitude of each listing so we can visualize it on a map.*/
SELECT id
, ROUND(latitude, 5) AS latitude
, ROUND(longitude, 5) AS longitude
FROM dbo.listings;


/*In this query we are lumping the different property types as 'house stays,' 'apartment stays,' 'secondary_unit_stays,' and 
'unique_stays.' For a few of the propety types, I was not sure where to group them. For example, for the property type 'Entire 
guesthouse' is a little ambiguous because while it is a secondary stay, it could also be categorized as a house stay. However,
for simplicity sake, I am using my best judgement here.*/
--In this first cte, we are counting each property type and grouping them to use for the next cte.
WITH ct_property_types AS(
SELECT property_type
, CAST(COUNT(property_type) AS float) as ct_property
FROM dbo.listings
GROUP BY property_type)
--In this next cte, we are manually grouping the different property types and finding the sum as either house stays, apartment stays,
--secondary unit stays, or unique stays.
, ct_four_property_types AS(
SELECT SUM(CASE WHEN property_type IN ('Entire cottage','Entire home','Entire loft','Entire place','Entire rental unit',
'Entire townhouse','Entire vacation home','Entire villa') THEN ct_property ELSE 0 END) AS house_stays
, SUM(CASE WHEN property_type IN ('Entire condo', 'Entire serviced apartment') THEN ct_property ELSE 0 END) AS apartment_stays
, SUM(CASE WHEN property_type IN ('Entire guest suite','Entire guesthouse','Private room','Private room in bed and breakfast',
'Private room in bungalow','Private room in cabin','Private room in camper/rv','Private room in castle','Private room in condo',
'Private room in cottage','Private room in farm stay','Private room in guest suite','Private room in guesthouse',
'Private room in home','Private room in hostel','Private room in hut','Private room in loft','Private room in rental unit',
'Private room in townhouse','Private room in treehouse','Private room in vacation home','Room in bed and breakfast',
'Room in boutique hotel','Room in hotel','Shared room in home','Shared room in hostel','Shared room in rental unit'
) THEN ct_property ELSE 0 END) AS secondary_unit_stays
, SUM(CASE WHEN property_type IN ('Barn','Bus','Camper/RV','Campsite','Casa particular','Entire bungalow','Entire cabin',
'Entire chalet','Farm stay','Shipping container','Tent','Tiny home','Treehouse','Yurt') THEN ct_property ELSE 0 END) AS unique_stays
FROM ct_property_types)
--This last cte is finding the total amount of all stays so we can use it for calucation for the outer query.
,ct_totals AS (
SELECT house_stays + apartment_stays + secondary_unit_stays + unique_stays as total_stays
FROM ct_four_property_types
)
--This laster outer query is selecting all the different stays and finding the percentange from the total.
SELECT house_stays
, ROUND((house_stays / (SELECT total_stays from ct_totals)) * 100, 2) AS house_stays_pct
, apartment_stays
, ROUND((apartment_stays / (SELECT total_stays from ct_totals)) * 100, 2) AS apartment_stays_pct
, secondary_unit_stays
, ROUND((secondary_unit_stays / (SELECT total_stays from ct_totals)) * 100, 2) AS secondary_unit_stays_pct
, unique_stays
, ROUND((unique_stays / (SELECT total_stays from ct_totals)) * 100, 2) AS unique_stays_pct
FROM ct_four_property_types;


/*It's a known fact that superhosts earn more than 60% on average than standard hosts. We are comparing hosts to superhost status to
see if we can find what superhosts are doing better to earn an average of 60% more revenue*/
SELECT CASE WHEN host_is_superhost = 't' THEN 'superhost' ELSE 'host' END as host_is_superhost
, ROUND(AVG(host_response_rate), 2) AS response_rate
, ROUND(AVG(host_acceptance_rate), 2) AS acceptance_rate
, FLOOR(AVG(availability_365)) AS annual_availibility
, ROUND(AVG(price), 2) AS price
, ROUND(AVG(review_scores_rating), 2) AS overall_rating
, ROUND(AVG(review_scores_accuracy), 2) AS accuracy_rating
, ROUND(AVG(review_scores_cleanliness), 2) AS cleanliness_rating
, ROUND(AVG(review_scores_location), 2) AS location_rating
, ROUND(AVG(review_scores_value), 2) AS value_rating
FROM dbo.listings
GROUP BY host_is_superhost
--This is a simple analysis that indicates superhosts do slightly better accross the board. The only major difference is that
--superhosts charge more on average. I had a hunch that people tend to favor superhosts from a psychological standpoint. However,
--this query proves that this is not the case. Regular hosts tend to be less available but only slightly. In conclusion, because 
--superhosts have a higher rating, they can justify listing a higher price. Thus, it explains why superhosts earn more on average.



