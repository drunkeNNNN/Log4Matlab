function setTextFileLogLevel(level)
    l=Log4M.Logger.getInstance();
    l.setTextFileLogLevel(level);
    l.setLogLevel(max([l.getLogLevel(),level]));
end