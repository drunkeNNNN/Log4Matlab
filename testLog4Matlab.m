clear;
clc;

l=Log4Matlab.getInstance();
l.clearAppenders();
l.addAppender(Appenders.CommandWindow().setLogLevel(Log4Matlab.INFO));
% l.addAppender(Appenders.TextFile().setLogLevel(Log4Matlab.INFO));
% l.addAppender(Appenders.TextFile().setLogLevel(Log4Matlab.INFO).setOutputFilePath('NoPrefix.log'));
% l.addAppender(Appenders.TextFile().setLogLevel(Log4Matlab.INFO).setOutputFilePath('Prefix.log',true));
ta=Appenders.Table().setLogLevel(Log4Matlab.ALL);
l.addAppender(ta);

% l.setAcceptFilter('class');
l.setAcceptFilter('');
l.addFilter(Filters.Regex().setRegex('cell')...
                           .onMatch(Filters.Filter.DENY)...
                           .onMismatch(Filters.Filter.ACCEPT));

l.info('This is an info about numbers: ',[8,9]);
aFunctionLogging(l);
try
    aFunctionWithAnError();
catch e
    l.error('A non-fatal error occurred',e);
end

LogTestClass().aClassMethodLogging();
LogTestClass.aStaticClassMethodLogging();

itemNames=cell(2,1);
itemNames{1}='item A';
itemNames{2}='item B';
itemNames{3}='item C';
l.info('cell array print: ',itemNames);

itemValues=[10;20;30];

testTable=table(itemNames,itemValues);
l.warn('Table data out of spec: ',testTable);

parfor i=1:3
    l.info('thread : Logging from a parfor loop');
end

l.fatal('A fatal error occurred');

function aFunctionWithAnError()
    error('Log4Matlab:testing','test error message');
end

function aFunctionLogging(logger)
    logger.info('Logging from a nested function');
end