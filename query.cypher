//Load csv file into Neo4j import environment
LOAD CSV WITH HEADERS FROM 'file:///travel.csv' AS line

//created two nodes each for my source and destination
MERGE(source:Location{name:line.Origin_city, airport_code:line.Origin_airport})
MERGE(dest:Location{name:line.Destination_city, airport_code:line.Destination_airport})

//finally created the relationship for each source and destination and 2 more features for this project - distance and date of flight
CREATE(source)<-[:COMING_FROM{origin_population: toInteger(line.Origin_population)}]-(f:Flight{id:toInteger(line.ROW_ID), distance:toInteger(line.Distance),origin_population: line.Origin_population,destination_population: line.Destination_population, fly_date: datetime({ epochMillis: apoc.date.parse(line.Fly_date, 'ms', 'dd/MM/YYYY') })})-[:GOING_TO{Destination_population:toInteger(line.Destination_population)}]->(dest)

//====================================================================

//showing relationship between the take off point of the flight and final destination
MATCH(source:Location)<-[:COMING_FROM]-(f)-[:GOING_TO]-(dest:Location)

//selected the city I want to use as location
WHERE source.name contains "Albany, NY" 

//return 3 fields, the origin name (take off city), the row ID and Destination
RETURN source.name as Origin, f.id as ROW_ID, dest.name as Destination 

//=======================================================================

//selected a location we want to depart from
MATCH(source:Location)<-[:COMING_FROM]-(f)-[:GOING_TO]-(dest:Location)

//chose the city I want and the fly date
where source.name contains "Albany, NY" and date(f.fly_date) = date("2002-12-30")

//returned 3 columns, city, fly date and the row ID
RETURN source.name as city, date(f.fly_date), f.id as ROW_ID
//======================================================================

//selected a location we want to depart from
MATCH(source:Location)<-[:COMING_FROM]-(f)-[:GOING_TO]-(dest:Location)

//chose the city I want and the fly date
where tointeger(f.destination_population) > 5000000 and source.name contains "Albany, NY"  and date(f.fly_date) = date("2002-12-30")

//returned 3 columns, the population threshold, the city, fly date and the row ID
RETURN source.name as city,tointeger(f.destination_population) as `destination population`, date(f.fly_date), f.id as ROW_ID

//========================================================================

//created a relationship between the origin of flight in f1 to a city which is the source for second flight f2 to destination
MATCH(source:Location)<-[:COMING_FROM]-(f1)-[:GOING_TO]->(source2:Location)<-[:COMING_FROM]-(f2)-[:GOING_TO]-(dest:Location)

//I added this clause to make sure that, the destination is not equal to to the second take off point.
where dest.name <> source2.name

//returned the origin of flight, the destination, the city of first stop and then the IDs for both flights
RETURN source.name as origin, dest.name as destination, source2.name as `middle city`,  f1.id as id_1, f2.id as id_2


//=========================================================================

//selected a location we want to depart from and go to
MATCH(source:Location)<-[:COMING_FROM]-(f)-[:GOING_TO]-(dest:Location)

//named the cities I want to check the condition for and counted the the numbr of airports in each cities and saved as airport
with source.name as cities, count(dest.airport_code) as airports

where airports>1

//returned the count of the cities that are more than one
RETURN COUNT(cities) as `number of cities`
//===============================================================================

//created new label called Flight
MATCH(f:Flight)

//check the distance field under the new label of our node
RETURN f.distance as distance

//order by descending order
ORDER BY distance DESC

//select just the first value since it's in descending order
LIMIT 1 