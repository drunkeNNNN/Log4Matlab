% Convenience wrapper for info log. Call log.init(filename) first.
function info(varargin)
    logger=Log4M.Logger.getInstance();
    logger.debug(varargin{:});
end