# AviationFlightScraper
AviationFlightScraper done for UROP project for the analysis for flight paths
1)Under (location_of_country <- line5) change the tag "Singapore" to any country that is to be scrapped. E.G (Narita)
##CAUTION: some cities/countries will throw back error, such as "Kuala Lumpur"; instead key in "kuala+lumpur".
It is best to first check using "https://flightplandatabase.com/search?q=Singapore" to see which countries give results

2)I have not implemented any save function, so you'll have to run the full code until the end to get all the results.
##CAUTION: If the script is stopped halfway it will return a CSV file (in the same folder) as incomplete.
