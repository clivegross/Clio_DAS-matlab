function get_missingintraday(conn)
% this function fills in missing intra-day data over the last 5 trading
% days

% todays date as serial and 5 days ago as serial
today_num = datenum(date);
day5ago_num = datenum(date)-5;
% trading days in last 5 days as serial
trade_dates = busdays(day5ago_num, today_num, 1, '');

% get all ASX company IDs and codes from asxcompanycodes table
query = 'SELECT ASX_ID, ASX_code FROM asxcompanycodes WHERE 1';
data = fetch(conn,query);
[Ncodes c] = size(data);
t = 0;
h = waitbar(0,'Checking ASX intra-day data for missing dates');
for n = 1:Ncodes
    tic
    fprintf('\n%1.0f of %1.0f- ', n, Ncodes)
    asxid =  cell2mat(data(n,1));
    asxcode = cell2mat(data(n,2));
    
    % fetch array containing dates that we already have intraday data for
    query = ['SELECT DISTINCT FLOOR(timestmp_MAT) ', ...
        'FROM asxintradayprices ', ...
        'WHERE timestmp_MAT > ' num2str(day5ago_num), ...
        ' && ASX_ID = ' num2str(asxid)];
    dates_have = fetch(conn, query);
    dates_have = cell2mat(dates_have);
    
    % get array of date serials missing in db
    dates_havent = setdiff(trade_dates, dates_have);
    
    % 
    if ~isempty(dates_havent)
        fprintf('%1.0f dates missing, now fetching from Yahoo\n', numel(dates_havent))
        
        % get all intraday quotes available from Yahoo from last 5 days
        intraday_mat = get_IntraDayQuotes(asxcode,5);
        
        % trim intraday_mat down to intraday data from required dates (date serials from dates_havent array)
        tf = ismember(floor(intraday_mat), dates_havent);
        intraday_mat = intraday_mat(tf, :);
        
        % write to database
        write_intraday2db(conn, intraday_mat, asxid)
        
    else
        disp('This stock is already up to date')
        
    end
    t=t+toc;
    tRem = t*(Ncodes-n)/n;
    fprintf('%2.1f%% complete\n%3.1f minutes remaining\n',100*n/Ncodes,tRem/60)
    waitbar(n/Ncodes)
end
close(h)

