clear all;
log.init();

logger=Log4M.Logger.getInstance();
logger.setLogLevel(Log4M.LogLevel.OFF);

N=1000;
t=tic;
for i=1:N
    log.trace('Log ',i);
end
logger.setLogLevel(Log4M.LogLevel.INFO);
log.info('Time taken: ',toc(t)/N,'s per denied log message.');