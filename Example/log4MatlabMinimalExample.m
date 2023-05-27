clear all;
clc;
import Log4Matlab.*;

%% Setup Logger instance
logger=Logger.getInstance();
logger.setLogLevel(LogLevel.TRACE);
logger.addAppender(Appenders.CommandWindow().setLogLevel(LogLevel.INFO));
logger.addAppender(Appenders.TextFile().setLogLevel(LogLevel.TRACE)...
                                       .setOutputFilePath('Trace.log',true));

%% Basic logging
logger.info('Hello Log4Matlab.');
logger.info('This is a split message containing chars,'," strings, and the number pi ",pi,'.');
logger.info('You can also log datetime ',datetime('now'),' and duration objects ',datetime("now")-datetime('yesterday'),'.');
logger.trace('This message does not print and is filtered out. Change log level above to TRACE to print.');
logger.warn('Logging an alarming row vector: ',rand(1,3),' with additional line content.');

%% Logging in different code areas.
aScriptFunctionLogging(logger);
LogExampleClass().aClassMethodLogging();
LogExampleClass.aStaticClassMethodLogging();


%% Logging complex data types
% Numeric matrices
logger.info('Logging a 4x3 matrix: ',rand(4,3));

% Cell arrays.
itemNames=cell(2,1);
itemNames{1}='item A';
itemNames{2}='item B';
itemNames{3}='item C';
logger.trace('Cell array print: ',itemNames);

function aScriptFunctionLogging(logger)
    logger.info('Logging from a nested function. Notice the link changing.');
end