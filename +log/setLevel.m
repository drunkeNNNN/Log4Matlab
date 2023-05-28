function setLevel(newLogLevel)
    logger=Log4M.Logger.getInstance();
    logger.setLogLevel(newLogLevel);
end