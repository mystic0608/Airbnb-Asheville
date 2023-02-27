# Airbnb Asheville - Data Analysis with SQL and Tableau

As someone who is interested in data analysis, I sought after a dat aset and stumbled upon http://insideairbnb.com. This website provides dozens of data sets for many cities, including international. As I scrolled through, I found Asheville, NC on the list of data sets provided. At the time, I was planning a trip to visit Asheville and I thought this would be a perfect opportunity to explore the data and highlight some of the skills I have learned over the years.

# Data Exploration and Visually Appealing Insights

I dove into this project with a few things in mind - how can I utilize this data set and transform it into actionable insights? And how can I make those insights visually digestable? 

Firstly, I took these tables and did some cleaning. I mainly took several columns and removed them as they were not pertinent to my analysis. I double checked for any NULL values and found no duplicates. Fortunately, when you're working with a data set that isn't scraped from the web, you tend to be able to work with clean data sets - which is a crucial step in any analysis.

After exporting those tables into SQL server, I began exploring the data. What possible insights could I unravel with my SQL abilities? Knowing that I would have limited space on a Tableau dashboard, I settled with a few queries that may be the most beneficial from a business perspective:

* How many hosts have multiple listings? I decided to expand further. How many hosts have 1 listing? 2? 3? 4? 5-10? 11-50? 50+?
* Because I am working with data going back to a single year, I decided to find each quarter's fiscal revenue by room type, as well as the total revenue for that quarter.
* In another query, I wanted the longitude and latitude of each listing so I can display it beautifully on a map.
* There are mainly four different property types that Airbnb utilizes. I decided to group them together and display it as a percentage on a donut chart.

# Conclusion

Without further ado, here is my [SQL code](https://github.com/mystic0608/Airbnb-Asheville/blob/main/Airbnb_queries.sql).

And here is my Tableau dashboard.

Final thoughts - this data set was a blast to work with. Not only did I gain some valuable skills, but I learned a lot about the potential hiccups that a real data analyst might run into. A lot of the courses that I took and books that I have read do not teach you about some of the nuances you may encounter in a project from start to finish. With this project wrapped up, I am excited to start a new project where I scrape my own data set.
