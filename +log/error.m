% Convenience wrapper for error log. Call log.init(filename) first.
function error(varargin)
    logger=Log4M.Logger.getInstance();
    logger.error(varargin{:});
end