% Google Geocoding API Parameters
encodeEndpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address=';
encodekey = 'AIzaSyB01DLDrWoP_1YCO4JmClVS3YuLLPMuy4A';

% Uber API Parameters
priceEndpoint = 'https://api.uber.com/v1/estimates/price?';
timeEndpoint = 'https://api.uber.com/v1/estimates/time?';
uberKey = 'EzMgvoAsfghxFtgynJbUh5MhGsM00Oy5kInmeGyF';

%GOOGLEAPI

%Calling function for pickup and dropoff locations
[pickup, destination] = pickup_dropoff();

%Call function to convert pickup and dropoff locations to url format
[formatpickup, formatdestination] = urlformatter(pickup, destination);

%Call function to create googleAPI urls
urlpickup = googleurl(formatpickup, encodeEndpoint, encodekey);
urldestination = googleurl(formatdestination, encodeEndpoint, encodekey);

%Error Checker
[statuspickup, statusdestination] = errorchecker(urlpickup, urldestination);
while isequal(statuspickup, 'ZERO_RESULTS') || isequal(statusdestination, 'ZERO_RESULTS')

    %Call function for pickup and dropoff locations
    [pickup, destination] = pickup_dropoff();

    %Call function to convert pickup and dropoff locations to url format
    [formatpickup, formatdestination] = urlformatter(pickup, destination);

    %Call function to create googleAPI urls
    urlpickup = googleurl(formatpickup, encodeEndpoint, encodekey);
    urldestination = googleurl(formatdestination, encodeEndpoint, encodekey);
  
    %Error Checks Again
    [statuspickup, statusdestination] = errorchecker(urlpickup, urldestination);

end

%Call function to get longitude and latitude
[lngpickup, latpickup] = lnglatgetter(urlpickup);
[lngdestination, latdestination] = lnglatgetter(urldestination);

%Uber Prices API
uberPricesURL = strcat('https://api.uber.com/v1/estimates/price?', 'start_latitude=', num2str(latpickup), '&start_longitude=',... 
                num2str(lngpickup), '&end_latitude=', num2str(latdestination), '&end_longitude=', ...
                num2str(lngdestination), '&server_token=', uberKey);
try
    uberPrices = webread(uberPricesURL);
catch
    disp('Error, distance may exceed 100 miles');
    uberEverywhere;
end

fprintf('\nTrip Distance: %.2f miles.\n', uberPrices.prices(1).distance);
fprintf('Trip Duration: %.1f minutes.\n', uberPrices.prices(1).duration);
disp('------------------------ ');

%Uber Times API
uberTimesURL = strcat('https://api.uber.com/v1/estimates/time?', 'start_latitude=', num2str(latpickup), '&start_longitude=',... 
                num2str(lngpickup), '&end_latitude=', num2str(latdestination), '&end_longitude=', ...
                num2str(lngdestination), '&server_token=', uberKey);
uberTimes = webread(uberTimesURL);

fprintf('%s: %s \n Current Wait Time: %d minutes\n\n\n', uberPrices.prices(3).localized_display_name, ...
        uberPrices.prices(3).estimate, (uberTimes.times(3).estimate)/60);
    
for i = 1:length(uberTimes.times)
        fprintf('%s: %s | Surge Multipliter: %.1f \n Current Wait Time: %d minutes\n\n\n', uberPrices.prices(i).localized_display_name, ...
        uberPrices.prices(i).estimate, uberPrices.prices(i).surge_multiplier, (uberTimes.times(i).estimate/60));
end

