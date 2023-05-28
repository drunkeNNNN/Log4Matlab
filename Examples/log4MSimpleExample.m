% Convenience wrapper for Log4M classes. One-Line calls.
clc;

% Only console output
% log.init();

% Console and file output
FILENAME='convenicence.log';
log.init(FILENAME);

% Optional: configure LogLevel. Otherwise, all messages are printed
% log.setLevel(Log4M.LogLevel.TRACE);

% Optional: configure message filter
log.setFilter({'number','about',1});

log.trace('A trace log with numbers: ',rand(1,3));
log.debug('A debug log with a datetime: ',datetime('now'),' and a number ',500*randn(1));
log.info('Trajectory info: ',array2table(rand(3,2),'VariableNames',{'t/s','y/mm'}));
log.warn('A warn log about a ',"string");
log.error('An error log: something went wrong.');
log.fatal('A fatal log.');