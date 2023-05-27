% Convenience wrapper for debug log. Call log.init(filename) first.
function debug(varargin)
    logger=Log4M.Logger.getInstance();
    logger.debug(varargin{:});
end