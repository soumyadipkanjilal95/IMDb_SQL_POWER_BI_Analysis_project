
/* 
Project - IMDb Movie analysis in MYSQL

This dataset is basically a mysql script which is based on IMDb movies and related informations . 
I have open the sql script in my workbench and then ran it completely . Then we got a database named
imdb . In this Database we have 6 different tables . Each table has different informations and we have 
few tables with foreign keys . 

The first thing to check in the data cleaning part is to check whether any column of any table has null 
values and if it has then how many it is . We have got a few columns with moderate number of null values 
and some columns have too many null values in it . If the columns have too many null values then we have 
dropped those columns otherwise only the null rows have been deleted . Some column names have been renamed 
to make it more useable and easy .  

Data analysis part --

1. The data analysis in SQL basically depends on what is required by the organization or client . In this 
project i have tried to make use of all the essential sql commands and functions to optimize our queries and
make the queries faster and stop code duplication . 

2. Text functions like REGEXP and LIKE operators have been used to optimize character based data searching . 
If we take the exact query and just change the characters that we need then it can fetch the data more faster . 

3. VIEWS and SUBQUERIES have been used to stop code duplication and it will also save some time . Views 
are executed with Inner joins between multiple tables . Now we can just call the view by it's name and it will 
show us all the details . So multiple joining is not required . 

SUBQUERY is another very important function in SQL . Subquery helps to find the data without joining so it will 
reduce the time needed for data fetching . Subquery also plays a huge part when we want to find like the second
highest or third lowest in any column . Here i have used Subqueries to get the Movie with third highest votes on
IMDb . 

4. PROCEDURES , TEMPORARY TABLES and INDEXES are used to make the data analysis much quicker and smoother . I 
have created two different procedures . One will basically show the details of a Production company and another will show 
the details of any actor or actresses . Procedures are best for query optimization and it also stops data 
duplication or code reuse . We just need to call the Procedure with it's name and give the input value by which 
it will give us all the pre defined outputs . 
Example : if we give the name ('Akshay Kumar') inside the paranthesis after calling our Procedure with call 
function then it will show all the details of actor 'Akshay Kumar' Like total movies , total_votes , total
duration , avg rating etc .

Temporary tables on the other hand is very useful if we need some particular insight of our data for a short 
time because the temporary table will be dropped automatically when we close our mysql workbench . I have also 
created one Index inside the temporary table to make our query more faster . 

5. GROUP BY , ORDER BY and WHERE clause are used in almost every query along with other Mathematical operators
like SUM , COUNT , AVG etc . 
INNER JOINS are also really really important because without joining we can't get 
any important details of our data and other joins like left , right or full joins will give so much null 
values .

6. In the last section of this project CTE's , WINDOWS FUCTIONS and IF-ELSE Statements are used to get a different
wholesome picture of our data . 

CTE can be used to basically break the query in two or more parts and it can 
simplify the code . CTE'S are basically a temporary named result set .

Windows Fuctions are really important if we want to get the RANK or DENSE RANK of any particular column . I have 
mostly used Dense Rank function in this project . This function shows the Rank based on values of any particular 
column . We need to give the parameters on which the value will show the result .
Order by and Partition by are often used with windows functions .

If-Else statement is just like pythons conditional logic or if-else . If any given parameter meets a criteria then
it will show the predefined statement otherwise it will move to next criteria and if it does not match with any criteria then it will 
go to else statement . I have created a column called Total_Films_Bucket with If-Else Statement .
*/

## Selecting the Database that we want with USE function .

USE IMDB ;

## Watching all the tables and columns .

SELECT * FROM DIRECTOR_MAPPING ;
SELECT * FROM GENRE ;
SELECT * FROM MOVIE ;
SELECT * FROM NAMES ;
SELECT * FROM RATINGS ;
SELECT * FROM ROLE_MAPPING ;

## Using IS NULL function to check if any column has null values .

SELECT * FROM MOVIE WHERE WORLWIDE_GROSS_INCOME IS NULL ;
SELECT * FROM MOVIE WHERE LANGUAGES IS NULL ;
SELECT * FROM MOVIE WHERE PRODUCTION_COMPANY IS NULL ;

## Deleting those rows where the Language or Production_company column has null values .

DELETE FROM MOVIE WHERE LANGUAGES IS NULL ;
DELETE FROM MOVIE WHERE PRODUCTION_COMPANY IS NULL ;

SELECT * FROM MOVIE ;

## Dropping a particular column with DROP function .

ALTER TABLE MOVIE 
DROP COLUMN Worlwide_gross_income ;

SELECT * FROM MOVIE ;

## Using RENAME inside ALTER function to change the column name .

ALTER TABLE MOVIE 
RENAME COLUMN YEAR TO Release_year ;

## Using IS NULL function to check if any column has null values .

SELECT * FROM GENRE WHERE GENRE IS NULL ;

SELECT * FROM NAMES WHERE HEIGHT IS NULL ;
SELECT * FROM NAMES WHERE DATE_OF_BIRTH IS NULL ;
SELECT * FROM NAMES WHERE KNOWN_FOR_MOVIES IS NULL ;

## Dropped Height,Date_of_birth and Known_for_movies column because it has too many null or missing values .

ALTER TABLE NAMES
DROP COLUMN HEIGHT ; 
ALTER TABLE NAMES
DROP COLUMN DATE_OF_BIRTH ;
ALTER TABLE NAMES 
DROP COLUMN KNOWN_FOR_MOVIES ;

## Watching the data again after cleaning it .

SELECT * FROM NAMES ;
SELECT * FROM RATINGS ;
SELECT * FROM ROLE_MAPPING ;
SELECT * FROM MOVIE ;
SELECT * FROM GENRE ;
SELECT * FROM DIRECTOR_MAPPING ;

SELECT * FROM RATINGS WHERE MEDIAN_RATING IS NULL ;
SELECT * FROM ROLE_MAPPING WHERE CATEGORY IS NULL ;

## Using REGEXP and text functions --

## Using REGEXP to get only those Movies Where the Country is India and Title starts with 'A'

SELECT * FROM MOVIE WHERE COUNTRY = 'INDIA' 
AND TITLE REGEXP '^[A]';

/* Using REGEXP and IN operator to get those Movies Where the Languages are Indian Languages and 
the Movie title starts and end with A,E,I,O,U .*/

SELECT * FROM MOVIE WHERE LANGUAGES IN ('HINDI','TAMIL','BENGALI','TELEGU','MALAYALAM','KANNADA','PUNJABI')
AND TITLE REGEXP '^[AEIOU].*[AEIOU]$' ;

## Using the Like operator to get only those Movies whose title has only 6 letters . 

SELECT * FROM MOVIE WHERE TITLE LIKE '______' ;

SELECT * FROM MOVIE ;
SELECT * FROM NAMES ;
SELECT * FROM ROLE_MAPPING ;
SELECT * FROM RATINGS ;

/* Creating a VIEW by joining multiple tables with inner join to see each Movies Actors name , 
Categories ,Duration, Country , Avg_rating and Total_votes . */ 

CREATE VIEW VW_ACTOR_MOVIES AS
(SELECT M.ID,M.TITLE,M.DATE_PUBLISHED,M.DURATION,
M.COUNTRY,N.NAME,RM.CATEGORY,R.AVG_RATING,R.TOTAL_VOTES
FROM NAMES N INNER JOIN ROLE_MAPPING RM
ON N.ID=RM.NAME_ID 
INNER JOIN MOVIE M ON M.ID=RM.MOVIE_ID 
INNER JOIN RATINGS R ON R.MOVIE_ID=M.ID) ;

SELECT * FROM VW_ACTOR_MOVIES ;

/* Creating a VIEW by joining two tables and using Windows function which is Dense Rank .
This view shows The Film title , Release_year , Avg_rating, Rating_rank , Total_votes etc */

CREATE VIEW VW_MOVIE_RANK AS
(SELECT M.ID,TITLE,RELEASE_YEAR,DURATION,PRODUCTION_COMPANY,
AVG_RATING,TOTAL_VOTES , DENSE_RANK() OVER (ORDER BY AVG_RATING DESC) 
AS RATING_RANK FROM MOVIE M INNER JOIN RATINGS R ON
R.MOVIE_ID=M.ID 
ORDER BY AVG_RATING DESC) ;

SELECT * FROM VW_MOVIE_RANK ;

/* Getting the Movie with third highest Total_votes using subquery and
and then use some join and Order By and Limit function .*/

SELECT * FROM(SELECT M.ID AS MOVIE_ID ,M.TITLE,R.AVG_RATING,R.TOTAL_VOTES
FROM MOVIE M INNER JOIN RATINGS R ON
M.ID=R.MOVIE_ID ORDER BY TOTAL_VOTES DESC LIMIT 3) AS 
THIRD_HIGHES_VOTE ORDER BY TOTAL_VOTES ASC LIMIT 1 ;

## Getting only those columns fro Movie table where the duration is divisible by two .

SELECT * FROM MOVIE WHERE DURATION%2=0 ;

/* Extracting the Film with second highest votes using subquery and then checked the 
result with normal join between two tables .*/

SELECT * FROM MOVIE WHERE ID IN(
SELECT MOVIE_ID FROM RATINGS WHERE TOTAL_VOTES IN(
SELECT MAX(TOTAL_VOTES) FROM RATINGS WHERE TOTAL_VOTES NOT IN(
SELECT MAX(TOTAL_VOTES) FROM RATINGS))) ; 

SELECT * FROM RATINGS R INNER JOIN MOVIE M
ON R.MOVIE_ID=M.ID ORDER BY TOTAL_VOTES DESC LIMIT 2 ;

/* Using Subqueries instead of Joins to get only those actors and actresses
 who have worked in Horror or Comedy Movies .*/

SELECT * FROM NAMES WHERE ID IN(
SELECT NAME_ID FROM ROLE_MAPPING WHERE MOVIE_ID IN( 
SELECT ID FROM MOVIE WHERE ID IN( 
SELECT MOVIE_ID FROM GENRE WHERE GENRE IN('Horror','Comedy')))) ;

## CREATING PROCEDURES AND TEMPORARY TABLES

/* Creating a Procedure which will show the details of a Production Company . 
This procedure will show a Production companies total film count , avg length ,
avg_rating, total_votes, max and min duration . 
We just need to Call the procedure with it's name and then put the input and then run it .*/

DELIMITER //
CREATE PROCEDURE P_PRODUCTION_COMPANY_DETAILS (PRODUCTION_NAME VARCHAR (200))
BEGIN
SELECT PRODUCTION_COMPANY, COUNT(ID) AS TOTAL_FILM_COUNT ,
ROUND(AVG(DURATION),2) AS AVG_FILM_LENGTH,
ROUND(AVG(AVG_RATING),2) AVG_FILM_RATING, SUM(TOTAL_VOTES) AS TOTAL_VOTES,
MAX(DURATION) HIGHEST_LENGTH_FILM , MIN(DURATION) SHORTEST_FILM
FROM MOVIE M INNER JOIN RATINGS R ON
M.ID=R.MOVIE_ID 
GROUP BY PRODUCTION_COMPANY 
HAVING PRODUCTION_COMPANY=PRODUCTION_NAME ;
END //

CALL P_PRODUCTION_COMPANY_DETAILS('Marvel Studios') ;

/* Creating a Procedure which will show the details of an Actor or Actress . 
This procedure will show an Actor's total film count , their films avg length ,
avg_rating, total_votes, max Rating and max Votes . 
We just need to Call the procedure with it's name and then put the input and then run it .
Procedure is mainly used to reduce the code duplication and it also reduce the search duration */

DELIMITER //
CREATE PROCEDURE P_ACTOR_INFORMATION (ACTOR_NAME VARCHAR(200))
BEGIN
SELECT N.NAME,COUNT(M.ID) AS TOTAL_FILM,
ROUND(AVG(M.DURATION),2) AS AVG_DURATION , ROUND(AVG(R.AVG_RATING),2) AS AVG_RATING,
SUM(R.TOTAL_VOTES) AS TOTAL_VOTES , MAX(R.AVG_RATING) AS MAX_RATING,
MAX(R.TOTAL_VOTES) AS MAX_VOTE
FROM NAMES N INNER JOIN ROLE_MAPPING RM ON
N.ID=RM.NAME_ID 
INNER JOIN MOVIE M ON M.ID=RM.MOVIE_ID 
INNER JOIN RATINGS R ON R.MOVIE_ID=M.ID
GROUP BY N.NAME 
HAVING N.NAME=ACTOR_NAME ;
END //

CALL P_ACTOR_INFORMATION ('Akshay Kumar') ;

/* Creating a Temporary table which will show the Rating,Duration,Total_votes
and Ranking based on highest Avg_rating in that particular 
Year . I have used windows function which is Dense Rank along with Partition By 
Release_year column is used to Partition our ranking based on each different Year . */

CREATE TEMPORARY TABLE TEMP_RELEASE_YEAR_RATING AS
SELECT RELEASE_YEAR , TITLE , AVG_RATING, DURATION,
TOTAL_VOTES , DENSE_RANK() OVER 
(PARTITION BY RELEASE_YEAR ORDER BY AVG_RATING DESC) AS TOP_RATING_BY_EACH_YEAR
FROM MOVIE M INNER JOIN RATINGS R ON
M.ID=R.MOVIE_ID ;

SELECT * FROM TEMP_RELEASE_YEAR_RATING ;

## Creating an index in this temporary table which will help to fetch the data more faster .

CREATE INDEX IDX_TEMP_RELEASE_RATING ON TEMP_RELEASE_YEAR_RATING(TITLE) ;

## CTE'S,WINDOWS FUNCTION,IF-ELSE

/* Creating a CTE with Group by, If-Else statement and other mathematical operation to group 
the data by Film Genre . Each Genre will show its total no of films , avg_ratings, Total_votes 
and the If-Else statement . The query also used an Order by to show the Genre from highest no of votes to lowest . */

WITH MOVIE_RATINGS AS(
SELECT * FROM MOVIE M INNER JOIN RATINGS R ON
M.ID=R.MOVIE_ID) 
SELECT G.GENRE,COUNT(MR.ID) AS TOTAL_FILMS, ROUND(AVG(MR.AVG_RATING),2) 
AS AVG_RATINGS, SUM(MR.TOTAL_VOTES) AS TOTAL_VOTES,
CASE
WHEN COUNT(MR.ID)>3000 THEN "Total Films more than 3000"
WHEN COUNT(MR.ID)>2000 THEN "Total films between 2000-3000"
WHEN COUNT(MR.ID)>1000 THEN "Total films between 1000-2000"
WHEN COUNT(MR.ID)>500 THEN "Total films between 500-1000"
ELSE "Total films less than 500"
END AS TOTAL_FILMS_BUCKET
FROM MOVIE_RATINGS MR INNER JOIN
GENRE G ON MR.ID=G.MOVIE_ID 
GROUP BY G.GENRE ORDER BY TOTAL_VOTES DESC ;

/* Creating a CTE with Group by, Windows function and other mathematical operation to group 
the data by Month_of_publishing and Year_of_publishing. We have a column called Published_date from where 
Month and Year have been extracted with Extract function . 
This query show the statistics of different findings in IMDb(Year and Month wise) . 
A new column named Avg_vote_per_film have been created to show how a single movie had performed in a month at the
voting_area in IMDb. */

WITH ACTOR_FILMS_CTE AS(
SELECT M.ID ,RM.NAME_ID,DATE_PUBLISHED,DURATION,AVG_RATING,
TOTAL_VOTES FROM MOVIE M INNER JOIN RATINGS R ON 
M.ID=R.MOVIE_ID 
INNER JOIN ROLE_MAPPING RM ON RM.MOVIE_ID=M.ID) 
SELECT EXTRACT(YEAR FROM DATE_PUBLISHED) AS PUBLISHED_YEAR,
EXTRACT(MONTH FROM DATE_PUBLISHED) AS PUBLISHED_MONTH,
COUNT(AFC.ID) AS TOTAL_FILMS,
SUM(DURATION) AS TOTAL_MINS, ROUND(AVG(AVG_RATING),2) AS AVG_RATING,
ROUND(SUM(TOTAL_VOTES)/COUNT(AFC.ID),2) AS AVG_VOTE_PER_FILM,
SUM(TOTAL_VOTES) AS TOTAL_VOTES, COUNT(N.ID) AS TOTAL_ACTORS,
RANK() OVER (ORDER BY SUM(TOTAL_VOTES) DESC) AS VOTE_RANK
FROM ACTOR_FILMS_CTE AS AFC INNER JOIN NAMES N
ON N.ID=AFC.NAME_ID 
GROUP BY PUBLISHED_MONTH,PUBLISHED_YEAR ;

SELECT * FROM MOVIE ;

/* Creating a query to fetch all the Indian actors movie statistics . This query
will show each Indian actors ID, Name, Avg_rating they got from all of their films ,
Sum of total votes , Total count of movies they have done .
It also uses a windows function along with group by to show the actors with highest avg_rating from 
descending to ascending order .*/

SELECT COUNTRY,N.ID AS ACTOR_ID,NAME,
ROUND(AVG(AVG_RATING),2) AS AVG_RATING,SUM(TOTAL_VOTES) AS TOTAL_VOTES,
COUNT(M.ID) AS TOTAL_MOVIES ,
DENSE_RANK() OVER (ORDER BY ROUND(AVG(AVG_RATING),2) DESC) AS INDIAN_RATING_RANK
FROM MOVIE M INNER JOIN GENRE G ON
M.ID=G.MOVIE_ID
INNER JOIN RATINGS R ON R.MOVIE_ID=M.ID 
INNER JOIN ROLE_MAPPING RM ON RM.MOVIE_ID=M.ID
INNER JOIN NAMES N ON RM.NAME_ID=N.ID 
GROUP BY COUNTRY,N.ID,NAME
HAVING COUNTRY = 'INDIA' ;

/*
This is a very small dataset so we cannot do huge Data analysis with it but i have given a try
and there can be room for some more analysis which i cannot see now but i will definitely look
at it with another angle .
*/




