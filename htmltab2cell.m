% HTML table to cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract a table from html code and arrange into a RxC cell array,
% excluding headers
% INPUT:
%  urlcode- text string containing html code
%  ncol- number of columns in table
% OUTPUT:
%  datacell- cell array conversion from html table
%  nrows- number of rows in table
function [datacell nrows] = htmltab2cell(htmlcode,ncol)

% reduce data to start of table to end of table
n1 = strfind(htmlcode,'<table'); %index to beginning of table
n2 = strfind(htmlcode,'</table>'); %index to end of table
data = htmlcode(n1(1):n2(1));
% create vector of indices for string 'data' beginning 'cs' and end 'cf' of each table cell
cs = strfind(data,'<td');
cf = strfind(data,'</td>');
N = length(cs); %number of cells in table

% table dimensions
C=ncol; %number of columns
R=N/C; %number of rows
% sort data from website into RxC cell array
x = cell(R,C);
n=0;
for r=1:R
    for c=1:C
        n=n+1;
        x(r,c) = {data(cs(n)+4:cf(n)-1)};
    end
end

datacell = x;
nrows = R;