% Get Previous Day ASX Announcements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -get html code URL from http://www.asx.com.au/asx/statistics/prevBusDayAnns.do
% -extract html announcements table and convert to cell array 'datacell'
%  table columns have the following values:
%  ASX code | time published | price sensitive | headline | No. pages | PDF
% -replace price senstive column from html code to logical in 'datacell'
% -extract date string in variable 'dtstr' in format 'dd Month yyyy'
% requires function 'htmltab2cell.m' in same directory
function [datacell dtstr] = get_PDasxann

% retrieve html source code from website
urlcode = urlread('http://www.asx.com.au/asx/statistics/prevBusDayAnns.do');
% convert html announcements table to cell array
[X R] = htmltab2cell(urlcode,6);

% replace html code Price Sensitive column with logical
% (true == is price sensitive)
for i=1:R
    if ~isempty(strfind(cell2mat(X(i,3)),'pricesens'))
        X(i,3)={true};
    else
        X(i,3)={false};
    end
end
datacell = X;

% Create cell array containing Matlab time serial of each announcement
% get date string from URL code
nt1 = strfind(urlcode,'<title>Company Announcements published on '); %index beginning
nt2 = strfind(urlcode,'</title>'); %index end
dtstr = urlcode(nt1(1)+42:nt2(2)-1);




