% Convenience wrapper for trace log. Call log.init(filename) first.
function trace(varargin)
    logger=Log4M.Logger.getInstance();
    logger.trace(varargin{:});
end