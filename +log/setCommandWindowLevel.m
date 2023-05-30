function setCommandWindowLevel(level)
    l=Log4M.Logger.getInstance();
    l.setCommandWindowLevel(level);
    l.setLogLevel(max([l.getLogLevel(),level]))
end