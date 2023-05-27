% Convenience wrapper for fatal log. Call log.init(filename) first.
function fatal(varargin)
    logger=Log4M.Logger.getInstance();
    logger.fatal(varargin{:});
end