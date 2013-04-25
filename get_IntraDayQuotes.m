%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      get_IntraDayQuotes.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returns a matrix containing intra-day data for a specified ASX company
% retrieves data online from Yahoo Finance
% INPUT VARIABLES
% asxcode- string containing 3-letter ASX company code
% rng- integer representing the range of intra-day data where:
%         1 = today or most recent trading day
%         2 = the last trading week (5 days)
% OUTPUT VARIABLES
% IntraDayTable- Nx6 matrix containing columns of intra-day data where:
%              |          1         |   2  |  3   |  4  |   5   |   6    |
%              | MATLAB time serial | open | high | low | close | volume |
function IntraDayTable = get_IntraDayQuotes(asxcode,rng)

% Generate unique URL for input variables

% template URL string for company intra-day data 
urlnametemp = 'http://chartapi.finance.yahoo.com/instrument/1.0/TICKER.AX/chartdata;type=quote;range=PERIODd/csv';

% replace 'TICKER' with ASX company code in URL string
repstr1 = 'TICKER';
% generate new URL for stock
urlname = regexprep(urlnametemp, repstr1, asxcode);

% replace 'PERIOD' with required range of intra day data (rng=1 range=1day, rng=2 range=1week)
if rng <= 1
    range_str = '1';
else
    range_str = '2';
end
repstr2 = 'PERIOD';
% generate new URL for stock
urlname = regexprep(urlname, repstr2, range_str);

% Retreive data from generated yahoo finance API
is_connect = false;
count=0;
while ~is_connect
    
    try
        strdata = urlread(urlname);
        is_connect = true;
    catch exception
        
        disp('network connection down, trying again')
        count=count+1;
        pause(5)
        if count>100
            disp('100 attempts, internet is fucked')
            break
        end
    end

end

% Cut URL string down to intra-day quotes only
% index for line above intraday data
nt1 = strfind(strdata,'volume:');
% index for end of data
nt2 = length(strdata);   
% cut string data down
strdata = strdata(nt1:nt2);

% Save remaining URL string as .csv file
% replace colons with commas for csv format
strdata = regexprep(strdata, ':', ',');
% define file format as string for filename
form = '.csv';
% generate filename string
tempfilename = [asxcode 'temp' form];
% save intraday data as csv file (doesnt need comma delimiting as data already
% is comma separated, hence ''
dlmwrite(tempfilename, strdata, '');

% Open .csv file and store intra-day quotes in matrix
% open file and skip to line before intraday data starts
fid = fopen(tempfilename);
% starting from line where intraday data starts and storing each line into
% row n in Nx6 matrix 'idmat'
n=0;
tline = fgetl(fid); % must be done twice!
tline = fgetl(fid);
idmat = zeros(1,6);
while ischar(tline) 
    n=n+1;    
    tvec = str2num(tline);
    if length(tvec)==6
        idmat(n,:) = tvec;
    end
    tline = fgetl(fid);    
end
% column values: m      1       |   2  |  3   |  4  |   5   |   6
%                   time serial | open | high | low | close | volume

% Delete .csv file after data has been stored in matlab matrix
fclose('all');
delete(tempfilename)

% Replace Unix time serial at GMT with Matlab time serial at EST 
[Ridmat Cidmat] = size(idmat);
if Ridmat == 1
    IntraDayTable = [];
else
dtvecGMT = datevec(unixtime2mat(idmat(:,1)));
dtvecEST = dtvecGMT; 
% EST = GMT + 10 hours, add 10 to hours element in date vector
% FIX THIS! CREATE FUNCTION THAT DETERMINES WHTHER AEST (GMT+10h) OR AEDT (GMT+11h) IS IN
% EFFECT
% http://australia.gov.au/about-australia/our-country/time
% Daylight Saving Time begins at 2am on the first Sunday in October and
% ends at 2am (which is 3am Daylight Saving Time) on the first Sunday in April.
dtvecEST(:,4) = dtvecEST(:,4)+10;
% replace time serial (column 1) in idmat with corrected time serial
idmat(:,1) = datenum(dtvecEST);

IntraDayTable = idmat;
end


