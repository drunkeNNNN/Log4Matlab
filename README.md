# Powerful Log4J port for MATLAB.
The logger is inspired by the popular [log4j framework](https://logging.apache.org/log4j/2.x/manual/). The main implemented features are:
- Logging to command window, files and memory
- Popular log level design
- Message regex filtering for loggers and appenders
- Fully deployment compatible
- Convenience interface for single line logs for small projects

## Features
### Convenience interface
The library offers a convenience interface for one-line logs and does not require manual string formatting. Various atomic data types (char, string, categorical, logical, numeric, datetime, duration, exceptions, as well as custom objects) and combined structures thereof (arrays, cell arrays, table, timetable,..) are casted automatically.
```matlab
FILENAME='convenicence.log';
log.init(FILENAME);

% Optional: configure LogLevel. Otherwise, all messages are printed
log.setLevel(Log4M.LogLevel.TRACE);

% Optional: configure message filter
% log.setFilter({'number','about'});

log.trace('A trace log with numbers: ',rand(1,3));
log.debug('A debug log with a datetime: ',datetime('now'),' and a number ',500*randn(1));
log.info('Trajectory info: ',array2table(rand(3,2),'VariableNames',{'t/s','y/mm'}));
log.warn('A warn log about a ',"string");
log.error('An error log: something went wrong.');
log.fatal('A fatal log.');
```
The console output is printed with links to the calling script for fast debugging (Do you remember which code line your logs came from? I don't...).
![alt text](../assets/log4m.png "Logo Title Text 1")

### Highly configurable for larger projects with multiple appenders and filters
```matlab
import Log4M.*

logger=Logger.getInstance();

% Configure the numeric format according to num2str for printing numbers.
logger.setNumericFormat('%3.3f\t');

% Configure log to console appender with no filters in debug level
logger.addAppender(Appenders.CommandWindow().setLogLevel(LogLevel.DEBUG));

% Configure text file appender which prints to a file with a time stamp
% prefix. A new file is created every time the script runs. Disable the
% verbose mode (source filenames and timestamps are not printed).
logger.addAppender(Appenders.TextFile().setLogLevel(LogLevel.TRACE)...
                                       .disableVerboseMode()...
                                       .setOutputFilePath('Trace.log',true));
				       
% Configure additional file appender, which always prints to the same file. Each
% time the script runs, logs are added to the bottom of the file.
logger.addAppender(Appenders.TextFile().setLogLevel(LogLevel.INFO)...
                                       .setOutputFilePath('PersistentInfoLog.log',false));

% Configure memory appender
memoryAppender=Appenders.Memory().setLogLevel(LogLevel.ERROR);
% Memory appender configured to exclusively print messages which match all
% regexes in the cell array.
memoryAppender.addFilter(Filters.Regex().setRegex({'table','item B'},Filters.Regex.MODE_ALL)...
                                        .onMatch(FilterAction.ACCEPT)...
                                        .onMismatch(FilterAction.DENY));
logger.addAppender(memoryAppender);
```
### Example files
- [Convenience Wrapper](../master/Examples/log4MSimpleExample.m)
- [Configuration Example](../master/Examples/log4MExample.m)
- [Advanced Example](../master/Examples/log4MAdvancedExample.m)
