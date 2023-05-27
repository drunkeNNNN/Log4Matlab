%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup
%%%%%%%%%%%%%%%%%%%%%%%%
% The following commands should be called once per program execution.
% Clear all logger instances (kept in persistent memory, not cleared with 'clear')
clear all;
clc;

% Import Library for convenience
import Log4Matlab.*;

%% Setup Logger instance
% Acquire the default logger instance. Further Logger instances can be
% created by passing a char identifier to getInstance
logger=Logger.getInstance();

% Methods to clear the appenders and filters (here for demonstration purpose; 
% done automatically when instance is created)
logger.clearAppenders();
logger.clearFilters();

% Configure the numeric format according to num2str for printing numbers.
logger.setNumericFormat('%3.3f\t');
%logger.setNumericFormat('%3.5E\t');

% Configure the format of links to files in the output (CommandWindow and Table appenders)
%logger.setFileLinkFormat(FileLinkFormat.OFF);
% logger.setFileLinkFormat(FileLinkFormat.FILENAME);
% logger.setFileLinkFormat(FileLinkFormat.CLASS_AND_METHOD);
% logger.setFileLinkFormat(FileLinkFormat.FULL);

%% Message filters and LogLevel
%% Hirarchy
% Logger1
%   logLevel1
%   logFilters1
%   <-Appender_1
%     logLevel_Appender_1
%     logFilters_Appender_1
%   <-Appender_2
%     logLevel_Appender_2
%     logFilters_Appender_2
% ...

%% Logging priority
% Logging priority is as follows (see obj.messageDoesPrint(...)):
% 1. Logger.LogLevel.OFF || all(Appender.logLevel==LogLevel.OFF) -> deny in logger
% 2. Any appender filter yields FilterAction.ACCEPT -> accept in specific appender
% 3. Any appender filter yields FilterAction.DENY -> deny in specific appender
% 4. Any logger filter yields FilterAction.ACCEPT -> accept in logger
% 5. Any logger filter yields FilterAction.DENY -> deny in logger
% 6. Message LogLevel <= Appender.logLevel &&
%    Message LogLevel <= Logger.logLevel -> accept in specific appender
% 7. -> deny

% Configure the logger's log level. For details on log levels and message
% filtering, see Logger.m and LogLevel.m
% Set to LogLevel.OFF to disable all logging.
logger.setLogLevel(LogLevel.TRACE);

% Add a regex filter to the logger: Always accept messages containing
% 'Cell'. Such messages can however be denied by appender filters.
logger.addFilter(Filters.Regex().setRegex({'PRINT THIS'})...
                                .onMatch(FilterAction.ACCEPT));

%% Configure Appenders
% 1.
% Configure log to console appender with no filters in debug level
logger.addAppender(Appenders.CommandWindow().setLogLevel(LogLevel.DEBUG));

% 2.
% Configure text file appender which prints to a file with a time stamp
% prefix. A new file is created every time the script runs. Disable the
% verbose mode (source filenames and timestamps are not printed).
logger.addAppender(Appenders.TextFile().setLogLevel(LogLevel.TRACE)...
                                       .disableVerboseMode()...
                                       .setOutputFilePath('Trace.log',true));
% 3.
% Configure text file appender, which always prints to the same file. Each
% time the script runs, logs are added to the bottom of the file.
logger.addAppender(Appenders.TextFile().setLogLevel(LogLevel.INFO)...
                                       .setOutputFilePath('PersistentInfoLog.log'));

% 4.
% Configure table appender (log data is stored in memory and a table can be
% acquired at runtime at any place in the code through
% logger.getInstance().getAppenders().
tableAppender=Appenders.Table().setLogLevel(LogLevel.ERROR);
% Table appender configured to exclusively print messages which match all
% regexes in the cell array.
tableAppender.addFilter(Filters.Regex().setRegex({'table','item B'},Filters.Regex.MODE_ALL)...
                                       .onMatch(FilterAction.ACCEPT)...
                                       .onMismatch(FilterAction.DENY));
logger.addAppender(tableAppender);

%%%%%%%%%%%%%%%%%%%%%%%%
%% Logging demonstration
%%%%%%%%%%%%%%%%%%%%%%%%
%% Simple messages
logger.info('Hello Log4Matlab.');
logger.info('This is a split message containing chars,'," strings, the number pi ",pi,'.');
logger.info('You can also log datetime ',datetime('now'),' and duration objects ',datetime("now")-datetime('yesterday'),'.');
% Logging a message which is not printed to the console due to its log level
logger.trace('This message does not print and is filtered out. Change log level above to TRACE to print.');
% A message with the same log level prints to the console due to the accept filter
% configured above (overriding the log level)
logger.trace('PRINT THIS <- this message prints.')

%% Logging in different code areas.
% The logger can either be passed or the
% instance can be dynamically acquired without explicit reference. The
% configuration above is retreived in any case. Notice the console output
% links pointing to the logger call.
aScriptFunctionLogging(logger);
LogExampleClass().aClassMethodLogging();
LogExampleClass.aStaticClassMethodLogging();

% Logging a caught error. The stack trace and links print to the console.
try
    aFunctionWithAnError();
catch e
    logger.error('A non-fatal error occurred',e,' and nothing happened.');
end

%% Logging complex data types
% Numeric matrices and vectors
logger.info('Logging a row vector: ',rand(1,3),' with additional line content.');
logger.info('Logging a column vector ',rand(3,1))
logger.info('Logging a matrix: ',rand(4,3));

% Cell arrays.
itemNames=cell(2,1);
itemNames{1}='item A';
itemNames{2}='item B';
itemNames{3}='item C';
logger.trace('Cell array print: ',itemNames);

% Logging a table
itemDates={datetime('yesterday');datetime('today');datetime('tomorrow')};
itemValues=[10;20;30];
testTableSmall=table(itemNames,itemDates,itemValues);
logger.debug('Small table data: ',testTableSmall);
largeItemValues=itemValues+100;
testTableLarge=table(itemNames,itemDates,largeItemValues);
logger.info('Large table data: ',testTableLarge);

% Retrieve the filtered messages in the table appender, display the output
logTable=tableAppender.getTable()

%% Performance
N=50;
t=tic;
for i=1:N
    logger.trace('Logging trace level performance');
end
logger.info([num2str(toc(t)/N),'s taken per dismissed log.']);

t=tic;
for i=1:N
    logger.warn('Logging warn level performance');
end
logger.info([num2str(toc(t)/N),'s taken per printed log.']);

%% Crashing program execution and logging the error.
LogExampleClass().aClassMethodCrashingFatally();

%% Helpers
function aFunctionWithAnError()
    error('Log4Matlab:example:identifier','This is a test error message.');
end

function aScriptFunctionLogging(logger)
    logger.info('Logging from a nested function. Notice the link changing.');
end