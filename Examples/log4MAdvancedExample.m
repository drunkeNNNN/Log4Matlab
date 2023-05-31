%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup
%%%%%%%%%%%%%%%%%%%%%%%%
% The following commands should be called once per program execution.
% Clear all logger instances (kept in persistent memory, not cleared with 'clear')
clear;
clc;

% Import Library for convenience
import Log4M.*;

%% Setup Logger instance
% Acquire the default logger instance. Further Logger instances can be
% created by passing a char identifier to getInstance
logger=Logger.getInstance();

% Methods to clear the appenders and filters from previous runs. Alternative: clear all;
logger.clearAppenders();
logger.clearFilters();

% Configure the numeric format according to num2str for printing numbers.
logger.setNumericFormat('%3.3f\t');
%logger.setNumericFormat('%3.5E\t');

% Configure the format of links to files in the output (CommandWindow and Table appenders)
%logger.setFileLinkFormat(FileLinkFormat.OFF);
% logger.setFileLinkFormat(FileLinkFormat.FILENAME);
logger.setFileLinkFormat(FileLinkFormat.SOURCE_NAME);
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
% Set to LogLevel.OFF to disable all logging.2
logger.setLogLevel(LogLevel.TRACE);

% Add a regex filter to the logger: Always accept messages containing
% 'Cell'. Such messages can however be denied by appender filters.
logger.addFilter(Filters.Regex().setRegex({'PRINT THIS'})...
                                .onMatch(FilterAction.ACCEPT)...
                                .onMismatch(FilterAction.NEUTRAL));

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
                                       .setOutputFilePath('PersistentInfoLog.log',false));

% 4.
% Configure memory appender (log data is stored in memory and a table can be
% acquired at runtime at any place in the code through
% logger.getInstance().getAppenders()).
memoryAppender=Appenders.Memory().setLogLevel(LogLevel.ALL);
% Memory appender configured to exclusively print messages which match all
% regexes in the cell array.
% memoryAppender.addFilter(Filters.Regex().setRegex({'table','item B'},Filters.Regex.MODE_ALL)...
%                                         .onMatch(FilterAction.ACCEPT)...
%                                         .onMismatch(FilterAction.DENY));
logger.addAppender(memoryAppender);

%%%%%%%%%%%%%%%%%%%%%%%%
%% Logging demonstration
%%%%%%%%%%%%%%%%%%%%%%%%
%% Simple messages
logger.info('Hello Log4M.');
logger.info('This is a split message containing chars,'," strings, and the number pi ",pi,'.');
logger.info('You can also log datetime ',datetime('now'),' and duration objects ',datetime("now")-datetime('yesterday'),'.');
% Logging a message which is not printed to the console due to its log level
logger.trace('This message does not print and is filtered out. Change log level above to TRACE to print.');
% A message with the same log level prints to the console due to the accept filter
% configured above (overriding the log level)
logger.trace('PRINT THIS <- two function handles horizontally: ',{@Log4M.Logger,@Log4M.Filters.Filter})
logger.trace('PRINT THIS <- two function handles vertically: ',{@Log4M.Logger;@Log4M.Filters.Filter})
logger.info('A random object: ',Log4M.LogLevel.DEBUG);
logger.info('An object with configured char fun: ',LogExampleClass());

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
catch ex
    logger.error('A non-fatal error occurred and nothing happened.',ex);
end

%% Logging complex data types
% Numeric matrices and vectors
logger.info('Logging a (1x3) row vector: ',rand(1,3),' with additional line content.');
logger.info('Logging a (3x1) column vector ',rand(3,1))
logger.critical('Logging a (4x3) matrix: ',rand(4,3));

% Cell arrays.
itemNames=cell(2,1);
itemNames{1}='item A';
itemNames{2}='item B';
itemNames{3}='item C';
logger.trace('Cell array print: ',itemNames);

% Logging a table
itemDates={datetime('yesterday');datetime('today');datetime('tomorrow')};
itemCats=categorical(["CAT_A";"CAT_BD";"CAT_BD"]);
itemValues=[10;20;30];
testTableSmall=table(itemNames,itemDates,itemCats,itemValues);
logger.debug('Small table data: ',testTableSmall);

largeItemValues=itemValues+100;
testTableLarge=table(itemNames,itemDates,itemCats,largeItemValues);
logger.info('Large table data: ',testTableLarge);

% Logging a timetable
testTimetable=timetable(vertcat(itemDates{:}),itemNames,itemCats,largeItemValues./1E3);
logger.warn('Logging timetable data: ',testTimetable);

%% Retrieve the filtered messages in the memory appender as a table
logTable=memoryAppender.getTable()
% Display and filter the data in post analysis
filteredLogTable=logTable(strcmp(logTable.LevelStr,'WARN'),:);

%% Crashing program execution and logging the error.
LogExampleClass().aClassMethodCrashingFatally();

%% Helpers
function aFunctionWithAnError()
    error('Log4M:example:identifier','This is a test error message.');
end

function aScriptFunctionLogging(logger)
    logger.info('Logging from a nested function. Notice the link changing.');
end

 function tableSelCallback(hObject,eventData)
    % get all links/cells from the table
    links        = get(hObject,'Data');
    % assuming single column so just need the first index to get the
    % selected link/cell
    if eventData.Indices(2)==3
        selectedLink = links{eventData.Indices(1),3}{1,1};
        file=regexp(selectedLink,'.+(?=\ \(Line)','match');
        file=file{1,1};
    
        lineNum=regexp(selectedLink,'(?<=Line )\d+(?=\))','match');
        lineNum=str2double(lineNum{1,1});
        % build the url - find where in the string we have http
        matlab.desktop.editor.openAndGoToLine(file, lineNum);
    end
 end