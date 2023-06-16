# Whether

Get localized weather reports.

## What is this?

This app is a my response to a code prompt with the following stipulations:

- Must be done in Ruby on Rails
- Accept an address as input
- Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- Display the requested forecast details to the user
- Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
- Display indicator if result is pulled from cache.

The prompt allowed flexibility with a lot of the implementation details and all the points are met in this app.

A few high level points of interest:

1. This application stores all of its data in Redis, caching both address lookups and weather data.  There is no traditional database involved because it wasn't needed.  If this were a real project we'd want to persist a lot more data.  Weather data is kept fresh through the inbuilt TTL mechanism on Redis keys.
2. Address lookup and verification is fiddly.  Making it more difficult on myself for no good reason, I combined the address data for two data providers / services (Smarty & Nominatim).  In order to run this application locally, you'll need credentials for Smarty.
3. Related to the above address point, it might be impossible to determine which locale a user means from their search text (ex. Moscow Russia versus Moscow Idaho), so I provide a "disambiguation" page for the user to drill down into.
4. OpenWeatherMap is the weather data provider I chose to use.  They also require creds to use their service.  They also offer address lookup, but I chose to do my own lookup as this is often how services are cobbled together in the real world.  I use the lat / lon lookup, extracting geo data from the address lookups.
5. The Rubygem Geocoder offers a consistent interface for working with geocoding services, and includes an option to cache results.  This option is turned on and should remain so.  Address data changes constantly, so in production a TTL should be applied to the address cache keys.
6. With no traditional RDBMS involved, I chose to organize most functions as PORO Services, skipping ActiveRecord.  I following service names with `.call` gives me a consistent visual indicator of what I'm dealing.  I do services a couple different ways which might be interesting to talk about.
7. Testing is demonstrated for WeatherByGeo.  Using VCR to capture and persist and present real data, so I didn't bother to get too deep into mocking / stubbing.  Stuck with minitest because why not.  I can add more tests, being mindful of time spent on this project.
8. Before coding anything, I made some mockups in static-ish ERB.  The routes file can point those out, and screenshots are in public/
9. All (limited) tests pass, and Rubocop is satisfied.  Guard was used during dev.
