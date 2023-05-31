% Convenience wrapper for critical log. Call log.init(filename) first.
function critical(varargin)
    logger=Log4M.Logger.getInstance();
    logger.critical(varargin{:});
end