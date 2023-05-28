% Default setup configuration for logger. A file appender is configured
% when a filename is passed in.
function init(filename)
    arguments
        filename char='';
    end
    import Log4M.*;
    logger=Logger.getInstance();
    logger.clearAppenders();
    logger.clearFilters();
    logger.setNumericFormat('%3.5f\t');
    logger.setFileLinkFormat(FileLinkFormat.SOURCE_NAME);
    logger.setLogLevel(LogLevel.TRACE);
    logger.addAppender(Appenders.CommandWindow().setLogLevel(LogLevel.ALL));

    if ~isempty(filename)
        logger.addAppender(Appenders.TextFile().setLogLevel(LogLevel.ALL)...
                                               .disableVerboseMode()...
                                               .setOutputFilePath(filename,true));
    end
end